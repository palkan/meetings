package ru.teachbase.events
{
import flash.events.Event;

public class AppEvent extends Event
	{
		
		public static const CORE_LOAD_COMPLETE:String = "coreComplete";
		public static const CORE_LOAD_ERROR:String = "coreError";
		public static const LOADING_STATUS:String = "loadingStatus";
		
		private var _statusText:String = "";
		private var _isFatal:Boolean = false;
		
		public function AppEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false, statusText:String = "", fatal:Boolean = false)
		{
			super(type, bubbles, cancelable);
			_statusText = statusText;
			_isFatal = fatal;
		}

		public function get isFatal():Boolean
		{
			return _isFatal;
		}

		public function get statusText():String
		{
			return _statusText;
		}

	}
}