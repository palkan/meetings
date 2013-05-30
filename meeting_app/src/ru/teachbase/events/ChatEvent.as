package ru.teachbase.events
{
import flash.events.Event;

import ru.teachbase.model.ChatMessage;

public class ChatEvent extends Event
	{
		
		public static const MESSAGE:String = "message";
		public static const CLEAR:String = "clear";
		//public static const START_PRIVATE_CHAT:String = "startPrivateChat";
		
		private var _message:ChatMessage;
		
		public function ChatEvent(type:String, value:ChatMessage = null, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			
			_message = value as ChatMessage;
		}

		public function get message():ChatMessage
		{
			return _message;
		}
		
	}
}