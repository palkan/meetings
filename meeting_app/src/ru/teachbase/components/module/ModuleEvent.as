package ru.teachbase.components.module
{
import flash.events.Event;

public class ModuleEvent extends Event
	{
		
		public static const MINMAX:String = "module_minmax";
		public static const SETTINGS:String = "module_settings";
		public static const REMOVE:String = "module_remove";
		public static const RESIZE:String = "module_resize";
        public static const INITED:String = "module_inited";
		
		
		private var _value:*;
		
		public function ModuleEvent(type:String, value:* = null, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			
			_value = value;
		}

		public function get value():*
		{
			return _value;
		}

		public function set value(value:*):void
		{
			_value = value;
		}

	}
}