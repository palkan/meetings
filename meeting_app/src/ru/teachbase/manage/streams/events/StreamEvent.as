package ru.teachbase.manage.streams.events
{
import flash.events.Event;

import ru.teachbase.manage.streams.model.StreamData;

public class StreamEvent extends Event
	{
		public static const STREAM:String = "stream";
		public static const STREAM_CHANGE:String = "stream_change";
		
		private var _stream:StreamData;
		
		public function StreamEvent(type:String, data:StreamData = null, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			_stream = data;
		}
		
		public function get stream ():StreamData {
			return _stream;
		}
		
		
	}
}