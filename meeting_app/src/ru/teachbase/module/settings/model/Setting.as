package ru.teachbase.module.settings.model
{
	public class Setting
	{
		
		private var _valueName:String;
		private var _value:Object;
		private var _callServer:Boolean;
		
		public function Setting(valName:String = '', val:Object = null, callServer:Boolean = false):void
		{
			_valueName = valName;
			_value = val;
			_callServer = callServer;
		}

		public function get valueName():String
		{
			return _valueName;
		}

		public function set valueName(value:String):void
		{
			_valueName = value;
		}

		public function get value():Object
		{
			return _value;
		}

		public function set value(value:Object):void
		{
			_value = value;
		}

		public function get callServer():Boolean
		{
			return _callServer;
		}


	}
}