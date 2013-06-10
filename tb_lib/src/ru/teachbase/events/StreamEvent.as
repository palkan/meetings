package ru.teachbase.events
{
import flash.events.Event;

import ru.teachbase.model.Stream;

public class StreamEvent extends Event
	{
		public static const STREAM:String = "stream";
		public static const STREAM_CHANGE:String = "stream_change";
		
		private var _stream:Stream;
		
		public function StreamEvent(type:String, data:Stream = null, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			_stream = data;
		}
		
		public function get stream ():Stream {
			return _stream;
		}
		
		
	}
}