package ru.teachbase.events
{
import flash.events.Event;

public class FileStatusEvent extends Event
	{
		
		public static const START:String = "start";
		public static const CANCEL:String = "cancel";
		public static const PROGRESS:String = "progress";
		public static const COMPLETE:String = "complete";
		public static const SELECTED:String = "selected";
		
		private var _value:*;
		
		public function FileStatusEvent(type:String, val:* = null, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			_value = val;
		}

		public function get value():*
		{
			return _value;
		}

		public function set value(val:*):void
		{
			_value = val;
		}

	}
}