package ru.teachbase.events
{
import flash.events.Event;

public class InitilizeEvent extends Event
	{
		public static const MANAGER_IS_INITILIZE:String = "initilizing_module";
		public static const MANAGER_INITILIZED:String = "module_initilized";
		
		private var _managerName:String;
	
		public function InitilizeEvent(type:String, value:String = "", bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			_managerName = value;
		}

		public function get managerName():String
		{
			return _managerName;
		}

	}
}