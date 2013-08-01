package ru.teachbase.module.chat.components
{
import flash.events.Event;

import ru.teachbase.module.chat.model.ChatRoom;

public class ChatElementEvent extends Event
	{
		public static const CHAT_ELEMENT_CLICK:String = "chat_element_click";
		
		private var _chatElement:ChatRoom;
		
		public function ChatElementEvent(type:String, value:ChatRoom, bubbles:Boolean=false)
		{
			super(type, bubbles, cancelable);
			_chatElement = value;
		}
		
		public function get chatElement():ChatRoom{
			return _chatElement;
		}
	}
}