package ru.teachbase.traits
{
import ru.teachbase.events.ChangeEvent;
import ru.teachbase.model.Packet;
import ru.teachbase.constants.PacketType;

[Event(name="changed", type="ru.teachbase.events.ChangeEvent")]
	
	
	public class LocaleTrait extends RTMPListener
	{
		public function LocaleTrait()
		{
			super(PacketType.LANGUAGE,true);
			_readyToReceive = true;
		}
		
		override protected function prepareInput(data:Object):Object{
			
			if(!(data is Packet)) return null;
			
			var p:Packet = data as Packet;
			
			return p.data; 
			
		}
		
		
		override protected function dispatchTraitEvent(data:Object):void{
			
			
			dispatchEvent(new ChangeEvent(ChangeEvent.CHANGED,"lang",true));
			
			
		}
		
	}
}