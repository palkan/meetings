/**
 * User: palkan
 * Date: 5/29/13
 * Time: 12:37 PM
 */
package ru.teachbase.model {
import flash.display.Stage;

import mx.core.FlexGlobals;

import ru.teachbase.components.web.MainApplication;
import ru.teachbase.manage.docs.DocsManager;
import ru.teachbase.manage.file.FileManager;

import ru.teachbase.manage.layout.LayoutManager;

import ru.teachbase.manage.Manager;
import ru.teachbase.manage.modules.ModulesManager;
import ru.teachbase.manage.publish.PublishManager;
import ru.teachbase.manage.rtmp.RTMPMediaManager;
import ru.teachbase.manage.session.SessionManager;

import ru.teachbase.manage.rtmp.RTMPManager;
import ru.teachbase.manage.session.model.CurrentUser;
import ru.teachbase.manage.session.model.Meeting;
import ru.teachbase.manage.settings.SettingsManager;

import ru.teachbase.manage.streams.StreamManager;
import ru.teachbase.tb_internal;

CONFIG::RECORDING{
    import ru.teachbase.manage.rtmp.RTMPPretender;
    import ru.teachbase.manage.streams.RecordStreamManager;
}

public class App {
    public static const meeting:Meeting = new Meeting();

    public static const user:CurrentUser = new CurrentUser();

    private static var _view:MainApplication;

    private static var _settingsManager:SettingsManager;

    private static var _fileManager:FileManager;


    //------------ constructor ------------//

    //------------ initialize ------------//

    //--------------- ctrl ---------------//


    tb_internal static function setView(value:MainApplication):void {
        _view = value;
    }


    public static function get view():MainApplication {
        return _view;
    }

    public static function get rtmp():RTMPManager {

        CONFIG::LIVE{
            return (Manager.getManagerInstance(RTMPManager, true) as RTMPManager);
        }

        CONFIG::RECORDING{
            return (Manager.getManagerInstance(RTMPPretender, true) as RTMPPretender);
        }
    }

    public static function get rtmpMedia():RTMPMediaManager {
        return (Manager.getManagerInstance(RTMPMediaManager, true) as RTMPMediaManager);
    }

    public static function get publisher():PublishManager {
        return (Manager.getManagerInstance(PublishManager, true) as PublishManager);
    }

    public static function get docs():DocsManager {
        return (Manager.getManagerInstance(DocsManager, true) as DocsManager);
    }

    public static function get session():SessionManager {
        return (Manager.getManagerInstance(SessionManager, true) as SessionManager);
    }

    public static function get layout():LayoutManager {
        return (Manager.getManagerInstance(LayoutManager, true) as LayoutManager);
    }

    public static function get modules():ModulesManager {
        return (Manager.getManagerInstance(ModulesManager, true) as ModulesManager);
    }

    public static function get streams():StreamManager {

        CONFIG::LIVE{
            return (Manager.getManagerInstance(StreamManager, true) as StreamManager);
        }

        CONFIG::RECORDING{
            return (Manager.getManagerInstance(RecordStreamManager, true) as RecordStreamManager);
        }
    }


    public static function get settings():SettingsManager {
        if (!_settingsManager)
            _settingsManager = new SettingsManager();

        return _settingsManager;
    }


    public static function get file():FileManager {
        if (!_fileManager)
            _fileManager = new FileManager();

        return _fileManager;
    }

    public static function get stage():Stage {
        if (FlexGlobals.topLevelApplication)
            return FlexGlobals.topLevelApplication.stage;

        return null;
    }

}
}
