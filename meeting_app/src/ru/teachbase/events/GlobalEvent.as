package ru.teachbase.events
{
import flash.events.Event;

public class GlobalEvent extends Event
	{
		public static const USER_LEAVE:String = "gl_user_leave";
		public static const USER_ADD:String = "gl_user_add";
		public static const START_PRIVATE_CHAT:String = "start_private_chat";
		
		private var _value:*;
		
		public function GlobalEvent(type:String, value:* = null, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			_value = value;
		}
		
		
		public static function addEventListener(type:String, listener:Function, useCapture:Boolean=false, priority:int=0, useWeakReference:Boolean=false):void{

			GlobalEventDispatcher.__tbevents::instance.addEventListener(type, listener, useCapture, priority, useWeakReference);
	
		}
		
		
	
		public static function removeEventListener(type:String, listener:Function, useCapture:Boolean=false):void{
			
			GlobalEventDispatcher.__tbevents::instance.removeEventListener(type, listener, useCapture);
			
		}
		
		
		public static function dispatch(type:String,value:*=null):void{
			
			GlobalEventDispatcher.__tbevents::instance.dispatchEvent(new GlobalEvent(type,value));
			
		}

		public function get value():*
		{
			return _value;
		}

		
	}
}