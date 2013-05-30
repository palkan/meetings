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

import ru.teachbase.manage.LayoutManager;

import ru.teachbase.manage.Manager;
import ru.teachbase.manage.SessionManager;
import ru.teachbase.manage.SessionManager;
import ru.teachbase.manage.SessionManager;

import ru.teachbase.manage.rtmp.RTMPManager;

public class App {
    private static var _focusManager:FocusManager;

    public static const room:RoomModel = new RoomModel();

    public static const user:CurrentUser;

    //------------ constructor ------------//

    public function App()
    {
    }

    //------------ initialize ------------//

    //--------------- ctrl ---------------//


    public static function get rtmp():RTMPManager{
        return (Manager.getManagerInstance(RTMPManager,true) as RTMPManager);
    }

    public static function get session():SessionManager{
        return (Manager.getManagerInstance(SessionManager,true) as SessionManager);
    }

    public static function get layout():LayoutManager{
        return (Manager.getManagerInstance(LayoutManager,true) as LayoutManager);
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
