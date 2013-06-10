package ru.teachbase.traits
{
import flash.events.ErrorEvent;

import ru.teachbase.events.ChangeEvent;
import ru.teachbase.model.Packet;
import ru.teachbase.constants.PacketType;

    [Event(name="changed", type="ru.teachbase.events.ChangeEvent")]
	[Event(name="error", type="flash.events.ErrorEvent")]
	
	public final class StateTrait extends RTMPListener
	{
		
		//------------ constructor ------------//
		
		public function StateTrait()
		{
			super(PacketType.STATE);
			_readyToReceive = true;
		}
		
		override protected function prepareInput(data:Object):Object{
			
			if(!(data is Packet)) return null;
			
			var p:Packet = data as Packet;
			
			return p.data; 
			
		}
		
		
		
		override protected function dispatchTraitEvent(data:Object):void{
			if(data.level === 'state')				
				dispatchEvent(new ChangeEvent(ChangeEvent.CHANGED, 'state', data.code));
			else if(data.level === 'error')
				dispatchEvent(new ErrorEvent(ErrorEvent.ERROR,false,false,data.text));
			
		}
		
		//------------ initialize ------------//
		
		//--------------- ctrl ---------------//
		
		//------------ get / set -------------//
		
		//------- handlers / callbacks -------//
		
	}
}