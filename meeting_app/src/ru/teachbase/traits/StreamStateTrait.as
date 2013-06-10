package ru.teachbase.traits
{
import ru.teachbase.events.ChangeEvent;
import ru.teachbase.model.Packet;
import ru.teachbase.constants.PacketType;

[Event(name="changed", type="ru.teachbase.events.ChangeEvent")]
	
	public final class StreamStateTrait extends RTMPListener
	{
		
		//------------ constructor ------------//
		
		public function StreamStateTrait()
		{
			super(PacketType.STREAM_STATUS,true);
			_readyToReceive = true;
		}
		
		override protected function prepareInput(data:Object):Object{
			
			if(!(data is Packet)) return null;
			
			var p:Packet = data as Packet;
			
			return p.data; 
			
		}
		
		
		
		override protected function dispatchTraitEvent(data:Object):void{
			
			
			dispatchEvent(new ChangeEvent(ChangeEvent.CHANGED, 'state', data));
			
			
		}
		
		//------------ initialize ------------//
		
		//--------------- ctrl ---------------//
		
		//------------ get / set -------------//
		
		//------- handlers / callbacks -------//
		
	}
}