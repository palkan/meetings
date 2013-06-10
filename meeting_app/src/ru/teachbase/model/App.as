/**
 * User: palkan
 * Date: 5/29/13
 * Time: 12:37 PM
 */
package ru.teachbase.model {
import flash.display.Stage;

import mx.core.FlexGlobals;
import mx.managers.FocusManager;
import mx.managers.IFocusManagerContainer;

import ru.teachbase.manage.layout.LayoutManager;

import ru.teachbase.manage.Manager;
import ru.teachbase.manage.modules.ModulesManager;
import ru.teachbase.manage.publish.PublishManager;
import ru.teachbase.manage.session.SessionManager;
import ru.teachbase.manage.session.SessionManager;
import ru.teachbase.manage.session.SessionManager;

import ru.teachbase.manage.rtmp.RTMPManager;
import ru.teachbase.manage.session.model.CurrentUser;
import ru.teachbase.manage.session.model.Meeting;
import ru.teachbase.manage.streams.StreamManager;

public class App {
    private static var _focusManager:FocusManager;

    public static const meeting:Meeting = new Meeting();

    public static const user:CurrentUser = new CurrentUser();

    //------------ constructor ------------//

    public function App()
    {
    }

    //------------ initialize ------------//

    //--------------- ctrl ---------------//


    public static function get rtmp():RTMPManager{
        return (Manager.getManagerInstance(RTMPManager,true) as RTMPManager);
    }

    public static function get publisher():PublishManager{
        return (Manager.getManagerInstance(PublishManager,true) as PublishManager);
    }

    public static function get session():SessionManager{
        return (Manager.getManagerInstance(SessionManager,true) as SessionManager);
    }

    public static function get layout():LayoutManager{
        return (Manager.getManagerInstance(LayoutManager,true) as LayoutManager);
    }

    public static function get modules():ModulesManager{
        return (Manager.getManagerInstance(ModulesManager,true) as ModulesManager);
    }

    public static function get streams():StreamManager{
        return (Manager.getManagerInstance(StreamManager,true) as StreamManager);
    }

    public static function get focusManager():FocusManager{
        if(!_focusManager)
            _focusManager=new FocusManager(FlexGlobals.topLevelApplication as IFocusManagerContainer);

        return _focusManager;
    }


    public static function get stage():Stage{
        if (FlexGlobals.topLevelApplication)
            return FlexGlobals.topLevelApplication.stage;

        return null;
    }

}
}
