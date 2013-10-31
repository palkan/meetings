/**
 * User: palkan
 * Date: 10/17/13
 * Time: 11:59 AM
 */
package ru.teachbase.controller {
import com.mangui.HLS.utils.Log;

import flash.events.Event;

import ru.teachbase.components.notifications.Notification;
import ru.teachbase.events.GlobalEvent;
import ru.teachbase.manage.Initializer;
import ru.teachbase.manage.LocaleManager;
import ru.teachbase.manage.Manager;
import ru.teachbase.manage.SkinManager;
import ru.teachbase.manage.docs.DocsManager;
import ru.teachbase.manage.layout.LayoutManager;
import ru.teachbase.manage.modules.ModulesManager;
import ru.teachbase.manage.rtmp.RTMPPretender;
import ru.teachbase.manage.session.SessionManager;
import ru.teachbase.manage.streams.RecordStreamManager;
import ru.teachbase.model.App;
import ru.teachbase.utils.shortcuts.config;
import ru.teachbase.utils.shortcuts.notify;
import ru.teachbase.utils.shortcuts.translate;

public class RecordingController extends ApplicationController {
    public function RecordingController() {
        super();
    }

    override public function dispose():void{
        const managers:Array = [App.streams,App.rtmp,App.session,App.modules,App.layout,App.docs];
        managers.forEach(function(mgr:Manager,ind:int,arr:Array):void{ mgr && mgr.clear();});
    }



    /**
     *  Reset all managers and reload history.
     */


    public function reset():void{

        GlobalEvent.dispatch(GlobalEvent.RESET);

        reinitialize();
    }

    override protected function reinitialize():void {

        _initializing = true;

        const managers:Array = [App.streams, App.rtmp, App.session, App.modules, App.layout, App.docs];

        managers.forEach(function (mgr:Manager, ind:int, arr:Array):void {
            mgr && mgr.clear();
        });

        addInitializerListeners(reinitializationComplete, reinitializationFailed);

        Initializer.reinitializeManagers.apply(null, managers);

    }


    override protected function reinitializationFailed(e:Event):void {

        _initializing = false;

        removeInitializerListeners(reinitializationComplete, reinitializationFailed);

        notify(new Notification(translate("connection_failed_again", "notifications")), true);

    }


    override protected function reinitializationComplete(e:Event):void {

        _initializing = false;

        removeInitializerListeners(reinitializationComplete, reinitializationFailed);

        GlobalEvent.dispatch(GlobalEvent.RECONNECT);

    }

    override public function initializeManagers():void{

        if(!config('hls/debug')) Log.LOGGING = false;

        _initializing = true;

        addInitializerListeners(managersInitializedHandler, managersErrorHandler, managersProgressHandler);

        Initializer.initializeManagers(
                LocaleManager.instance,  // loading locales
                SkinManager.instance,    // loading skin
                new RecordStreamManager(true),  //dummy manager for streams handling
                new RTMPPretender(true),    // connecting to rtmp server
                new SessionManager(true), // login, get user info (profile, role, permissions), get room info (id, settings, users etc) --> Session Model
                new ModulesManager(true),  // loading modules models, initialize active modules
                new LayoutManager(true),  // loading layout, positioning modules
                new DocsManager(true)
        );


    }

}
}
