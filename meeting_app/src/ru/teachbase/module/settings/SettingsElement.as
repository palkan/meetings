package ru.teachbase.module.settings
{

import mx.core.INavigatorContent;

import ru.teachbase.module.settings.model.Setting;
import ru.teachbase.module.settings.events.ChangeSettingsEvent;

import spark.components.Group;

public class SettingsElement extends Group implements INavigatorContent
	{
		public function SettingsElement()
		{
			super();
		}
		
		public function get label():String
		{
			return null;
		}
		
		public function get icon():Class
		{
			return null;
		}
		
		public function get creationPolicy():String
		{
			return null;
		}
		
		public function set creationPolicy(value:String):void
		{
		}
		
		public function createDeferredContent():void
		{
		}
		
		public function get deferredContentCreated():Boolean
		{
			return false;
		}
		
		protected function chagedStatusSend(name:String, value:Object, callServer:Boolean = false):void{
			dispatchEvent(new ChangeSettingsEvent(ChangeSettingsEvent.LOCAL_SETTINGS_CHANGE,new Setting(name,value,callServer)));
		}
	}
}