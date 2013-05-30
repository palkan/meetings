package ru.teachbase.module.chat.components
{
import flash.events.Event;

import ru.teachbase.model.PrivateChatElement;

public class ChatElementEvent extends Event
	{
		public static const CHAT_ELEMET_CLICK:String = "chat_element_click";
		
		private var _chatElement:PrivateChatElement;
		
		public function ChatElementEvent(type:String, value:PrivateChatElement, bubbles:Boolean=false)
		{
			super(type, bubbles, cancelable);
			_chatElement = value;
		}
		
		public function get chatElement():PrivateChatElement{
			return _chatElement;
		}
	}
}