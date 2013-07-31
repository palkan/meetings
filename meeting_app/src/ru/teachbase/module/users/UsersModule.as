package ru.teachbase.module.users
{
import ru.teachbase.manage.modules.model.IModuleContent;
import ru.teachbase.manage.modules.model.Module;
import ru.teachbase.manage.modules.model.ModuleSettings;
import ru.teachbase.model.App;
import ru.teachbase.utils.shortcuts.$null;
import ru.teachbase.utils.shortcuts.style;

/**
	 * @author Webils (created: Mar 11, 2012)
	 */
	public final class UsersModule extends Module
	{

        private var _settings:Vector.<ModuleSettings>;
		
		//------------ constructor ------------//
				
		public function UsersModule()
		{
			super("users");
			_icon = style("users","icon");
			_iconHover = style("users","iconHover");

            _settings = new <ModuleSettings>[];

            _settings.push(new ModuleSettings("export_user_list",ModuleSettings.FUN,$null)); // TODO: add this function!

			singleton = true;
		}
		
		//------------ initialize ------------//
		
		override protected function createInstance(instanceID:int):IModuleContent
		{
			instanceID = 1;
			var _el:UsersPanel = new UsersPanel();
			_el.instanceID = instanceID;
			_instances[instanceID] = _el;
			return _el;
		}
		
		public function clear():void
		{
			for each(var panel:UsersPanel in _instances)
				panel.clear();
		}
		
		//--------------- ctrl ---------------//
		//------------ get / set -------------//
		//------- handlers / callbacks -------//

    public function get settings():Vector.<ModuleSettings> {
        return _settings;
    }
}
}