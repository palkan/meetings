package ru.teachbase.traits
{
import ru.teachbase.events.ChatEvent;
import ru.teachbase.model.ChatMessage;
import ru.teachbase.model.Packet;
import ru.teachbase.model.constants.PacketType;

[Event(name="message", type="ru.teachbase.events.ChatEvent")]
	[Event(name="clear", type="ru.teachbase.events.ChatEvent")]
	
	public final class ChatTrait extends Trait
	{
		
		//------------ constructor ------------//
		
		public function ChatTrait(id:uint)
		{
			super(PacketType.CHAT);
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
			else
				dispatchEvent(new ChatEvent(ChatEvent.MESSAGE, message as ChatMessage));
				
		}
		
		//------------ get / set -------------//
		
		//------- handlers / callbacks -------//
		
	}
}