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

import ru.teachbase.assets.fonts.Pragmatica;
import ru.teachbase.components.web.MainApplication;
import ru.teachbase.events.AppEvent;
import ru.teachbase.events.ErrorCodeEvent;
import ru.teachbase.manage.Initializer;
import ru.teachbase.manage.LocaleManager;
import ru.teachbase.manage.layout.LayoutManager;
import ru.teachbase.manage.modules.ModulesManager;
import ru.teachbase.manage.notifications.NotificationManager;
import ru.teachbase.manage.SkinManager;
import ru.teachbase.manage.publish.PublishManager;
import ru.teachbase.manage.rtmp.RTMPManager;
import ru.teachbase.constants.ErrorCodes;
import ru.teachbase.manage.session.SessionManager;
import ru.teachbase.manage.streams.StreamManager;
import ru.teachbase.utils.Configger;
import ru.teachbase.utils.GlobalError;
import ru.teachbase.utils.shortcuts.translate;

[Event(type="ru.teachbase.events.AppEvent",name="")]

public class ApplicationController extends EventDispatcher{

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
                //TODO: reconnect
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
    }


    public function initialize(){

        Configger.instance.addEventListener(Event.COMPLETE, configLoaded);

        Configger.loadConfig();

    }



    protected function configLoaded(e:Event):void{
        initializeManagers();
    }


    public function initializeManagers(){

        addInitializerListeners();

        Initializer.initializeManagers(
                LocaleManager.instance,  // loading locales
                SkinManager.instance,    // loading skin
                new RTMPManager(true),    // connecting to rtmp server
                new SessionManager(true), // login, get user info (profile, role, permissions), get room info (id, settings, users etc) --> Session Model
                new ModulesManager(true),  // loading modules models, initialize active modules
                new LayoutManager(true),  // loading layout, positioning modules
                new StreamManager(true),  // subscribe to existing streams
                new PublishManager(true), // (local) mic/cam publishing
                new NotificationManager(true) // (local) notifications
        )


    }


    private function managersInitializedHandler(e:Event):void{

        removeInitializerListeners();
        _view.draw();
        dispatchEvent(new AppEvent(AppEvent.CORE_LOAD_COMPLETE));
    }

    private function managersProgressHandler(e:ProgressEvent):void {

        dispatchEvent(new AppEvent(AppEvent.LOADING_STATUS, false, false, "Managers initializing ... "+Math.round(e.bytesLoaded * 100 / e.bytesTotal)+"%"))

    }

    private function managersErrorHandler(e:ErrorEvent):void {

        removeInitializerListeners();
        dispatchEvent(new AppEvent(AppEvent.CORE_LOAD_ERROR, false, false, e.text, true));
    }

    private function addInitializerListeners():void{

        Initializer.instance.addEventListener(Event.COMPLETE, managersInitializedHandler);
        Initializer.instance.addEventListener(ProgressEvent.PROGRESS, managersProgressHandler);
        Initializer.instance.addEventListener(ErrorEvent.ERROR, managersErrorHandler);

    }

    private function removeInitializerListeners():void{

        Initializer.instance.removeEventListener(Event.COMPLETE, managersInitializedHandler);
        Initializer.instance.removeEventListener(ProgressEvent.PROGRESS, managersProgressHandler);
        Initializer.instance.removeEventListener(ErrorEvent.ERROR, managersErrorHandler);

    }
}
}
