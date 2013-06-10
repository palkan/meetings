package ru.teachbase.events
{
import flash.events.Event;

public class ShareEvent extends Event
	{
		
		
		public static const STOP_SHARING:String = "stop_sharing";
		
		private var _value:*;
		
		public function ShareEvent(type:String, value:*, bubbles:Boolean=false, cancelable:Boolean=false)
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