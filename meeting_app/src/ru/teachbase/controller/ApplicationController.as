/**
 * User: palkan
 * Date: 5/24/13
 * Time: 6:34 PM
 */
package ru.teachbase.controller {
import flash.events.ErrorEvent;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.ProgressEvent;
import flash.system.Security;
import flash.text.Font;
import flash.utils.setTimeout;

import ru.teachbase.assets.fonts.Pragmatica;
import ru.teachbase.components.notifications.Notification;
import ru.teachbase.components.settings.AudioSettings;
import ru.teachbase.components.settings.GeneralSettings;
import ru.teachbase.components.settings.VideoSettings;
import ru.teachbase.components.web.MainApplication;
import ru.teachbase.constants.ErrorCodes;
import ru.teachbase.events.AppEvent;
import ru.teachbase.events.ErrorCodeEvent;
import ru.teachbase.events.GlobalEvent;
import ru.teachbase.manage.Initializer;
import ru.teachbase.manage.LocaleManager;
import ru.teachbase.manage.Manager;
import ru.teachbase.manage.SkinManager;
import ru.teachbase.manage.docs.DocsManager;
import ru.teachbase.manage.layout.LayoutManager;
import ru.teachbase.manage.modules.ModulesManager;
import ru.teachbase.manage.publish.PublishManager;
import ru.teachbase.manage.rtmp.RTMPManager;
import ru.teachbase.manage.rtmp.RTMPMediaManager;
import ru.teachbase.manage.session.SessionManager;
import ru.teachbase.manage.streams.StreamManager;
import ru.teachbase.model.App;
import ru.teachbase.supervisors.InStreamSup;
import ru.teachbase.supervisors.OutStreamSup;
import ru.teachbase.tb_internal;
import ru.teachbase.utils.Configger;
import ru.teachbase.utils.GlobalError;
import ru.teachbase.utils.logger.Logger;
import ru.teachbase.utils.shortcuts.config;
import ru.teachbase.utils.shortcuts.debug;
import ru.teachbase.utils.shortcuts.notify;
import ru.teachbase.utils.shortcuts.translate;

use namespace tb_internal;

[Event(type="ru.teachbase.events.AppEvent", name="")]

public class ApplicationController extends EventDispatcher {

    private static const REINITIALIZE_INTERVAL:int = 5000;

    /**
     * Amount of time between connection drops which is OK
     *
     * If a period between drops is smaller than this value - set receiveVideo to false
     *
     * Equal to 5 minutes.
     *
     */

    private static const MIN_DROP_PERIOD:int = 5*60*1000;

    protected var _initializing:Boolean = false;

    private var _view:MainApplication;

    private var _reiniting:Boolean = false;

    private var _reinitCount:int = 0;

    private var _last_drop:Number=0;

    public function ApplicationController() {

        // security options

        (Security.sandboxType !== Security.APPLICATION) && Security.allowDomain("*.teachbase.ru"), Security.allowInsecureDomain("*.teachbase.ru");

        // settings fonts

        Font.registerFont(Pragmatica.Normal);
        Font.registerFont(Pragmatica.NormalN);
        Font.registerFont(Pragmatica.Bold);
        Font.registerFont(Pragmatica.BoldItalic);
        Font.registerFont(Pragmatica.Italic);

        // listen to global errors

        GlobalError.listen(onGlobalError);
    }

    protected function onGlobalError(e:ErrorCodeEvent):void {
        var errorMessage:String;

        dispose();

        switch (e.code) {
            case ErrorCodes.KICKEDOFF:
                _initializing = _reiniting = false;
                errorMessage = translate("kickedoff", "error");
                break;
            case ErrorCodes.LIMIT:
                _initializing = _reiniting = false;
                errorMessage = translate("limit", "error");
                break;
            case ErrorCodes.TIMEOUT:
                _initializing = _reiniting = false;
                errorMessage = translate("connection_timeout", "error");
                break;
            case ErrorCodes.MEETING_FINISHED:
                _initializing = _reiniting = false;
                errorMessage = translate("meeting_finished", "error");
                break;
            case ErrorCodes.AUTHORIZATION_FAILED:
                _initializing = _reiniting = false;
                errorMessage = translate("authorization_failed", "error");
                break;
            case ErrorCodes.CONNECTION_FAILED:
                errorMessage = translate("main_server", "error");
                if(App.view && !_initializing && !_reiniting){
                    _reiniting = true;
                    debug('reinitialize on timeout');
                    setTimeout(reinitialize, REINITIALIZE_INTERVAL);
                }
                break;
            case ErrorCodes.PING_TIMEOUT:
                if(App.view && !_initializing && !_reiniting){
                    _reiniting = true;
                    debug('reinitialize now (ping)!');
                    reinitialize();
                }else{
                    Initializer.instance.clear();
                    reinitializationFailed();
                    debug('reinitialize on timeout; failed before reinit');
                    setTimeout(reinitialize, REINITIALIZE_INTERVAL);
                }
                break;
            case ErrorCodes.HARD_TIMEOUT:
                _initializing = _reiniting = false;
                debug('Really weak channel. Failed...');
                errorMessage = translate("weak_channel","error");
                break;
            case ErrorCodes.CONNECTION_DROPPED:
                if(!_initializing && !_reiniting){
                    _reiniting = true;
                    debug('reinitialize now!');
                    reinitialize();
                }
                errorMessage = translate("main_server", "error");
                break;
            default:
                errorMessage = "Error: " + e.text;
                break;
        }

        if(errorMessage){
            hasEventListener(AppEvent.CORE_LOAD_ERROR) && dispatchEvent(new AppEvent(AppEvent.CORE_LOAD_ERROR, false, false, errorMessage, true));

            App.view && App.view.lightbox && App.view.lightbox.show();
            App.view && notify(new Notification(errorMessage), true);

            App.view && !_reiniting && App.view.failed(errorMessage);
        }
    }


    public function setView(view:MainApplication):void {
        _view = view;
        App.tb_internal::setView(view);
    }


    public function initialize():void {

        Configger.instance.addEventListener(Event.COMPLETE, configLoaded);

        Configger.loadConfig();

    }


    public function dispose():void {
        const managers:Array = [
            App.rtmp,
            //App.rtmpMedia,
            App.session,
            App.modules,
            App.layout,
            App.streams,
            App.docs,
            App.publisher];

        managers.forEach(function (mgr:Manager, ind:int, arr:Array):void {
            mgr && mgr.clear();
        });


        OutStreamSup.stop();
        InStreamSup.stop();
    }


    protected function configLoaded(e:Event):void {

        if (config('debug')) Logger.MODE = config('debug');

        debug(Configger.config);

        initializeManagers();
    }


    public function initializeManagers():void {

        _initializing = true;

        addInitializerListeners(managersInitializedHandler, managersErrorHandler, managersProgressHandler);

        Initializer.initializeManagers(
                LocaleManager.instance,  // loading locales
                SkinManager.instance,    // loading skin
                new RTMPManager(true),    // connecting to rtmp server
                //new RTMPMediaManager(true), // connecting for rtmp server again (stream connection),
                new SessionManager(true), // login, get user info (profile, role, permissions), get room info (id, settings, users etc) --> Session Model
                new ModulesManager(true),  // loading modules models, initialize active modules
                new LayoutManager(true),  // loading layout, positioning modules
                new StreamManager(true),  // subscribe to existing streams
                new DocsManager(true),
                new PublishManager(true) // (local) mic/cam publishing
        );


    }



    protected function reinitialize():void {

        debug("[main] init",arguments.callee);

        _initializing = true;

        notify(new Notification(translate("connection_failed", "notifications")), true);

        const managers:Array = [
            App.rtmp,
            //App.rtmpMedia,
            App.session,
            App.modules,
            App.layout,
            App.streams,
            App.docs,
            App.publisher];

        managers.forEach(function (mgr:Manager, ind:int, arr:Array):void {
            mgr && mgr.clear();
        });

        addInitializerListeners(reinitializationComplete, reinitializationFailed);

        Initializer.reinitializeManagers.apply(null, managers);

    }


    protected function reinitializationFailed(e:Event = null):void {

        _initializing = _reiniting = false;

        removeInitializerListeners(reinitializationComplete, reinitializationFailed);

        notify(new Notification(translate("connection_failed_again", "notifications")), true);

    }


    protected function reinitializationComplete(e:Event):void {

        _initializing = _reiniting = false;

        notify(new Notification(translate("connection_restored", "notifications")), true);

        removeInitializerListeners(reinitializationComplete, reinitializationFailed);

        config('net/monitor/out') && OutStreamSup.run(30000);
        config('net/monitor/in') && InStreamSup.run();

        const now:Number = (new Date()).getTime();

        if((++_reinitCount) > 1 && (now - _last_drop) < MIN_DROP_PERIOD){
            App.user.settings.receive_video = false;
            notify(new Notification(translate("video_turned_off", "notifications")), true);
        }

        _last_drop = now;

        App.streams.loadStreams();
        App.session.userReady();

        GlobalEvent.dispatch(GlobalEvent.RECONNECT);

        App.view && App.view.lightbox.close();
    }


    protected function managersInitializedHandler(e:Event):void {

        _initializing = false;

        removeInitializerListeners(managersInitializedHandler, managersErrorHandler, managersProgressHandler);

        CONFIG::LIVE{
            config('net/monitor/out') && OutStreamSup.run(30000);
            config('net/monitor/in') && InStreamSup.run();

            App.settings.addPanel(new AudioSettings());
            App.settings.addPanel(new VideoSettings());
            App.settings.addPanel(new GeneralSettings());
        }
        _view.draw();
        dispatchEvent(new AppEvent(AppEvent.CORE_LOAD_COMPLETE));
    }

    protected function managersProgressHandler(e:ProgressEvent):void {

        dispatchEvent(new AppEvent(AppEvent.LOADING_STATUS, false, false, "Managers initializing ... " + Math.round(e.bytesLoaded * 100 / e.bytesTotal) + "%"))

    }

    protected function managersErrorHandler(e:ErrorEvent):void {

        _initializing = false;

        removeInitializerListeners(managersInitializedHandler, managersErrorHandler, managersProgressHandler);
        dispose();
        dispatchEvent(new AppEvent(AppEvent.CORE_LOAD_ERROR, false, false, e.text, true));
    }

    protected function addInitializerListeners(complete:Function, failed:Function, progress:Function = null):void {

        Initializer.instance.addEventListener(Event.COMPLETE, complete);
        progress && Initializer.instance.addEventListener(ProgressEvent.PROGRESS, progress);
        Initializer.instance.addEventListener(ErrorEvent.ERROR, failed);

    }

    protected function removeInitializerListeners(complete:Function, failed:Function, progress:Function = null):void {

        Initializer.instance.removeEventListener(Event.COMPLETE, complete);
        progress && Initializer.instance.removeEventListener(ProgressEvent.PROGRESS, progress);
        Initializer.instance.removeEventListener(ErrorEvent.ERROR, failed);

    }
}
}
