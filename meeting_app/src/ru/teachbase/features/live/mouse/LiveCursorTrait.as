package ru.teachbase.features.live.mouse
{
import ru.teachbase.events.ChangeEvent;
import ru.teachbase.model.Packet;
import ru.teachbase.model.constants.PacketType;
import ru.teachbase.traits.ChainTrait;

/**
	 * Controller + trait-client
	 * @author Webils (created: May 14, 2012)
	 */
	
	[Event(name="changed", type="ru.teachbase.events.ChangeEvent")]
	
	public final class LiveCursorTrait extends ChainTrait
	{
		
		
		//------------ constructor ------------//
		
		public function LiveCursorTrait(id:int)
		{
			super(PacketType.CURSOR);
			_instanceId = id;
			_readyToReceive = true;
		}
		
		//------------ initialize ------------//
		
		//--------------- ctrl ---------------//
		override protected function prepareInput(data:Object):Object{
			
			if(!(data is Packet)) return null;
			
			var p:Packet = data as Packet;
			
			if(p.minstance != _instanceId) return null;
			
			return p; 
			
		}
		
		
		override protected function dispatchTraitEvent(data:Object):void{
			
			
			dispatchEvent(new ChangeEvent(ChangeEvent.CHANGED,null,data));
		}
		
		//------------ get / set -------------//
		
		//------- handlers / callbacks -------//
		
	}
}