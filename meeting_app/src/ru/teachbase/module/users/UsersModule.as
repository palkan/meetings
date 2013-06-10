package ru.teachbase.module.users
{
import ru.teachbase.manage.modules.model.IModuleContent;
import ru.teachbase.manage.modules.model.Module;
import ru.teachbase.utils.helpers.*;
import ru.teachbase.utils.shortcuts.style;

/**
	 * @author Webils (created: Mar 11, 2012)
	 */
	public final class UsersModule extends Module
	{
		
		//------------ constructor ------------//
				
		public function UsersModule()
		{
			super("users");
			_icon = style("users","icon");
			_iconHover = style("users","iconHover");
			
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
		
		/*public function addUser(room:Room, user:User):void
		{
			for each(var panel:UsersPanel in instances)
				panel.addUser(user);
		}
		
		public function removeUser(room:Room, user:User):void
		{
			for each(var panel:UsersPanel in instances)
				panel.removeUser(user);
		}
		*/
		//------------ get / set -------------//
		
		//------- handlers / callbacks -------//
		
	}
}