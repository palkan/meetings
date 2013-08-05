package ru.teachbase.module.users {
import ru.teachbase.manage.modules.model.IModuleContent;
import ru.teachbase.manage.modules.model.Module;
import ru.teachbase.manage.modules.model.ModuleSettings;
import ru.teachbase.model.App;
import ru.teachbase.model.User;
import ru.teachbase.utils.LocalFile;
import ru.teachbase.utils.shortcuts.style;

/**
 * @author Webils (created: Mar 11, 2012)
 */
public final class UsersModule extends Module {

    private var _settings:Vector.<ModuleSettings>;

    //------------ constructor ------------//

    public function UsersModule() {
        super("users");
        _icon = style("users", "icon");
        _iconHover = style("users", "iconHover");

        _settings = new <ModuleSettings>[];

        _settings.push(new ModuleSettings("export_user_list", ModuleSettings.FUN, exportList));

        singleton = true;
    }

    //------------ initialize ------------//

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

    //--------------- ctrl ---------------//
    //------------ get / set -------------//
    //------- handlers / callbacks -------//

    public function get settings():Vector.<ModuleSettings> {
        return _settings;
    }
}
}