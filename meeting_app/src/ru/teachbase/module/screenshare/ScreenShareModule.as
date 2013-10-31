package ru.teachbase.module.screenshare
{
import ru.teachbase.manage.modules.model.IModuleContent;
import ru.teachbase.manage.modules.model.Module;
import ru.teachbase.utils.helpers.*;
import ru.teachbase.utils.shortcuts.style;

public class ScreenShareModule extends Module
	{
		public function ScreenShareModule()
		{
			super("screenshare");
			
			_icon = style("screenshare","icon");
			_iconHover = style("screenshare","iconHover");
			
			singleton = true;
			
		}
		
		
		override protected function createInstance(instanceID:int):IModuleContent
		{
			instanceID = 1;
			var _el:ScreenShareContent = new ScreenShareContent();
			_el.instanceID = instanceID;
            _el.init();
			_instances[instanceID] = _el;
			return _el;
		}
	}
}