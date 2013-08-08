package ru.teachbase.module.users {
import ru.teachbase.components.callouts.SettingsItem;
import ru.teachbase.events.GlobalEvent;
import ru.teachbase.manage.modules.model.IModuleContent;
import ru.teachbase.manage.modules.model.Module;
import ru.teachbase.model.App;
import ru.teachbase.model.User;
import ru.teachbase.utils.LocalFile;
import ru.teachbase.utils.helpers.lambda;
import ru.teachbase.utils.shortcuts.$null;
import ru.teachbase.utils.shortcuts.style;

/**
 * @author Webils (created: Mar 11, 2012)
 */
public final class UsersModule extends Module {

    private var _settings:Vector.<SettingsItem>;

    //------------ constructor ------------//

    public function UsersModule() {
        super("users");
        _icon = style("users", "icon");
        _iconHover = style("users", "iconHover");

        _settings = new <SettingsItem>[];

        _settings.push(new SettingsItem("export_user_list", SettingsItem.FUN, exportList));

        singleton = true;
    }

    //------------ initialize ------------//

    //--------------- ctrl ---------------//

    override protected function createInstance(instanceID:int):IModuleContent {
        instanceID = 1;
        var _el:UsersPanel = new UsersPanel();
        _el.instanceID = instanceID;
        _instances[instanceID] = _el;
        return _el;
    }

    public function clear():void {
        for each(var panel:UsersPanel in _instances)
            panel.clear();
    }

    //--------------- API ----------------//

    public function exportList():void{

        const data:Array = App.meeting.usersList.source.map(function(u:User,ind:int, arr:Array):String{ return u.toCSVString();});

        LocalFile.save(data.join('\n'),'users_log.csv');

    }

    /**
     *
     * Return available settings for user.
     *
     * @param user
     * @return
     */

    public function userOptions(user:User):Vector.<SettingsItem>{

        const _s:Vector.<SettingsItem> = new <SettingsItem>[];

        (App.user.isAdmin() || user.iam) && _s.push(new SettingsItem('user_change_name',SettingsItem.FUN, $null));

        if(user.iam) return _s;

        _s.push(new SettingsItem('user_private_chat',SettingsItem.FUN, lambda(GlobalEvent.dispatch,GlobalEvent.START_PRIVATE_CHAT, user.sid)));

        if(!App.user.isAdmin()) return _s;

        var role:String;

        if (user.isAdmin()) {
            role = 'user';
        } else {
            role = 'admin';
        }

        _s.push(new SettingsItem('user_set_'+role,SettingsItem.FUN, lambda(App.session.setUserRole,user.sid,role)));

        _s.push(new SettingsItem('user_kick_off',SettingsItem.FUN, lambda(App.session.kickOff, user.sid)));

        return _s;
    }


    //------------ get / set -------------//

    public function get settings():Vector.<SettingsItem> {
        return _settings;
    }
}
}