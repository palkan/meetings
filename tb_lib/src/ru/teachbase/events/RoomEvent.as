package ru.teachbase.events
{
import flash.events.Event;

public class RoomEvent extends Event
	{
		
		public static const USERS_CHANGED:String = "users_changed";
		
		// TODO: Do we need a possibility to receive array?
		
		private var _data:*;
		
		public function RoomEvent(type:String, data:* = null, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			
			_data = data;
			
		}

		public function get data():*
		{
			return _data;
		}

	}
}