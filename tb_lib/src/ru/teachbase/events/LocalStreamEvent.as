package ru.teachbase.events
{
import flash.events.Event;

import ru.teachbase.model.LocalStream;

public class LocalStreamEvent extends Event
	{
		public static const VIDEO_CHANGED:String = "video_changed";
		
		private var _stream:LocalStream;
		
		public function LocalStreamEvent(type:String, data:LocalStream = null, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			_stream = data;
		}
		
		public function get stream():LocalStream {
			return _stream;
		}
		
		
	}
}