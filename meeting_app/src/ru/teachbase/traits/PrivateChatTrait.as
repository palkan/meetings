package ru.teachbase.traits
{
import ru.teachbase.module.chat.events.ChatEvent;
import ru.teachbase.module.chat.model.ChatMessage;
import ru.teachbase.model.Packet;
import ru.teachbase.constants.PacketType;

[Event(name="message", type="ru.teachbase.module.chat.events.ChatEvent")]
	[Event(name="clear", type="ru.teachbase.module.chat.events.ChatEvent")]
	
	public final class PrivateChatTrait extends RTMPListener
	{
		
		//------------ constructor ------------//
		
		public function PrivateChatTrait(id:uint)
		{
			super(PacketType.PRIVATE_CHAT);
			_instanceId = id;
		}
		
		//------------ initialize ------------//
		
		//--------------- ctrl ---------------//
		
		
		
		override protected function prepareInput(data:Object):Object{
			
			if(!(data is Packet)) return null;
			
			var p:Packet = data as Packet;
			
			if(p.minstance != _instanceId) return null;
			
			(p.data as ChatMessage).timestampS = Math.floor(p.timeS/1000);
			
			return p.data; 
			
		}
		
		
		override protected function dispatchTraitEvent(message:Object):void{
			
			if((message as ChatMessage).type === ChatMessage.CLEAR)
				dispatchEvent(new ChatEvent(ChatEvent.CLEAR));
			else if ((message as ChatMessage).type === ChatMessage.MESSAGE)
				dispatchEvent(new ChatEvent(ChatEvent.MESSAGE, message as ChatMessage));
				
		}
		
		//------------ get / set -------------//
		
		//------- handlers / callbacks -------//
		
	}
}