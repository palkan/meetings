package ru.teachbase.module.settings.events
{
import flash.events.Event;

import ru.teachbase.model.Setting;

public class ChangeSettingsEvent extends Event
	{
		public static const LOCAL_SETTINGS_CHANGE:String = 'local_settings_change';
		
		//private var _name:String;
		//private var _value:*;
		//private var _callServer:Boolean;
		private var _setting:Setting;
		
		//public function ChangeSettingsEvent(type:String, name:String, value:Object, callServer:Boolean = false)
		public function ChangeSettingsEvent(type:String, setting:Setting)
		{
			super(type, bubbles, cancelable);
			_setting = setting;
		//	_name = name;
		//	_value = value;
		//	_callServer = callServer;
		}

		/*public function get valueName():String
		{
			return _name;
		}

		public function get value():*
		{
			return _value;
		}

		public function get serverCall():Boolean
		{
			return _callServer;
		}

		*/

		public function get setting():Setting
		{
			return _setting;
		}

	}
}