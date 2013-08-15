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
import ru.teachbase.components.web.MainApplication;
import ru.teachbase.constants.ErrorCodes;
import ru.teachbase.events.AppEvent;
import ru.teachbase.events.ErrorCodeEvent;
import ru.teachbase.events.GlobalEvent;
import ru.teachbase.manage.Initializer;
import ru.teachbase.manage.LocaleManager;
import ru.teachbase.manage.Manager;
import ru.teachbase.manage.SkinManager;
import ru.teachbase.manage.layout.LayoutManager;
import ru.teachbase.manage.modules.ModulesManager;
import ru.teachbase.manage.publish.PublishManager;
import ru.teachbase.manage.rtmp.RTMPManager;
import ru.teachbase.manage.session.SessionManager;
import ru.teachbase.manage.streams.StreamManager;
import ru.teachbase.model.App;
import ru.teachbase.supervisors.InStreamSup;
import ru.teachbase.supervisors.OutStreamSup;
import ru.teachbase.tb_internal;
import ru.teachbase.utils.Configger;
import ru.teachbase.utils.GlobalError;
import ru.teachbase.utils.shortcuts.translate;

use namespace tb_internal;

[Event(type="ru.teachbase.events.AppEvent",name="")]

public class ApplicationController extends EventDispatcher{

    private static const REINITIALIZE_INTERVAL:int = 5000;

    private var _view:MainApplication;

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

    private final function onGlobalError(e:ErrorCodeEvent):void {
        var errorMessage:String;

        switch (e.code) {
            case ErrorCodes.KICKEDOFF:
                errorMessage = translate("kickedoff", "error");
                setTimeout(reinitialize,REINITIALIZE_INTERVAL); //todo: don't forget about it!
                break;
            case ErrorCodes.LIMIT:
                errorMessage = translate("limit", "error");
                break;
            case ErrorCodes.TIMEOUT:
                errorMessage = translate("connection_timeout", "error");
                break;
            case ErrorCodes.MEETING_FINISHED:
                errorMessage = translate("meeting_finished", "error");
                break;
            case ErrorCodes.AUTHORIZATION_FAILED:
                errorMessage = translate("authorization_failed", "error");
                break;
            case ErrorCodes.CONNECTION_FAILED:
                errorMessage = translate("main_server", "error");
                break;
            case ErrorCodes.CONNECTION_DROPPED:
                reinitialize();
                break;
            default:
                errorMessage = "Error: " + e.text;
                break;
        }

        hasEventListener(AppEvent.CORE_LOAD_ERROR) && dispatchEvent(new AppEvent(AppEvent.CORE_LOAD_ERROR, false, false, errorMessage, true));


        //TODO: show error state in MainApplication
    }


    public function setView(view:MainApplication):void{
        _view = view;
        App.tb_internal::setView(view);
    }


    public function initialize(){

        Configger.instance.addEventListener(Event.COMPLETE, configLoaded);

        Configger.loadConfig();

    }



    protected function configLoaded(e:Event):void{
        initializeManagers();
    }


    public function initializeManagers(){

        addInitializerListeners(managersInitializedHandler, managersErrorHandler, managersProgressHandler);

        Initializer.initializeManagers(
                LocaleManager.instance,  // loading locales
                SkinManager.instance,    // loading skin
                new RTMPManager(true),    // connecting to rtmp server
                new SessionManager(true), // login, get user info (profile, role, permissions), get room info (id, settings, users etc) --> Session Model
                new ModulesManager(true),  // loading modules models, initialize active modules
                new LayoutManager(true),  // loading layout, positioning modules
                new StreamManager(true),  // subscribe to existing streams
                new PublishManager(true) // (local) mic/cam publishing
        );


    }





    protected function reinitialize():void{

        const managers:Array = [App.rtmp,App.session,App.modules,App.layout,App.streams,App.publisher];

        managers.forEach(function(mgr:Manager,ind:int,arr:Array):void{ mgr.clear();});

        OutStreamSup.stop();
        InStreamSup.stop();

        addInitializerListeners(reinirializationComplete, reinitializationFailed);

        Initializer.reinitializeManagers.apply(null, managers);

    }



    private function reinitializationFailed(e:Event):void{

        removeInitializerListeners(reinirializationComplete,reinitializationFailed);

        //todo: show message

        setTimeout(reinitialize,REINITIALIZE_INTERVAL);

    }


    private function reinirializationComplete(e:Event):void{

        removeInitializerListeners(reinirializationComplete,reinitializationFailed);

        OutStreamSup.run(30000);
        InStreamSup.run();

        App.session.userReady();

        GlobalEvent.dispatch(GlobalEvent.RECONNECT);

    }



    private function managersInitializedHandler(e:Event):void{

        removeInitializerListeners(managersInitializedHandler, managersErrorHandler, managersProgressHandler);

        OutStreamSup.run(30000);
        InStreamSup.run();

        _view.draw();
        dispatchEvent(new AppEvent(AppEvent.CORE_LOAD_COMPLETE));
    }

    private function managersProgressHandler(e:ProgressEvent):void {

        dispatchEvent(new AppEvent(AppEvent.LOADING_STATUS, false, false, "Managers initializing ... "+Math.round(e.bytesLoaded * 100 / e.bytesTotal)+"%"))

    }

    private function managersErrorHandler(e:ErrorEvent):void {

        removeInitializerListeners(managersInitializedHandler,managersErrorHandler,managersProgressHandler);
        dispatchEvent(new AppEvent(AppEvent.CORE_LOAD_ERROR, false, false, e.text, true));
    }

    private function addInitializerListeners(complete:Function, failed:Function, progress:Function = null):void{

        Initializer.instance.addEventListener(Event.COMPLETE, complete);
        progress && Initializer.instance.addEventListener(ProgressEvent.PROGRESS, progress);
        Initializer.instance.addEventListener(ErrorEvent.ERROR, failed);

    }

    private function removeInitializerListeners(complete:Function, failed:Function, progress:Function = null):void{

        Initializer.instance.removeEventListener(Event.COMPLETE, complete);
        progress && Initializer.instance.removeEventListener(ProgressEvent.PROGRESS, progress);
        Initializer.instance.removeEventListener(ErrorEvent.ERROR, failed);

    }
}
}
