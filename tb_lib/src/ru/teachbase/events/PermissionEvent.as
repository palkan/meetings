package ru.teachbase.events
{
import flash.events.Event;

public class PermissionEvent extends Event
	{
		
		public static const PERMISSIONS_CHANGED:String = "permissions";
		
		private var _value:*;
		
		
		public function PermissionEvent(type:String, value:*, bubbles:Boolean=false, cancelable:Boolean=false)
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