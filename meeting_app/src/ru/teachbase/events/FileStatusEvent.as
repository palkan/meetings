package ru.teachbase.events
{
import flash.events.Event;

public class FileStatusEvent extends Event
	{
		
		public static const START:String = "tb:fs:start";
		public static const CANCEL:String = "tb:fs:cancel";
		public static const PROGRESS:String = "tb:fs:progress";
		public static const COMPLETE:String = "tb:fs:complete";
		public static const SELECTED:String = "tb:fs:selected";
        public static const PROCESSING:String = "tb:fs:processing";
        public static const PROCESSING_COMPLETE:String = "tb:fs:processing_complete";
		
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