package ru.teachbase.events
{
import flash.events.Event;

public class ScreenShareEvent extends Event
	{
		
		public static const START_SHARE:String = "tb_ss_start";
		public static const STOP_SHARE:String = "tb_ss_stop";
		public static const PREPARE_SHARE:String = "tb_ss_prepare";
		
		private var _uid:Number;
		private var _stream:String;
		
		public function ScreenShareEvent(type:String, uid:Number = 0, stream:String = null, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			
			_stream = stream;
			_uid = uid;
		}

		public function get uid():Number
		{
			return _uid;
		}

		public function get stream():String
		{
			return _stream;
		}


	}
}