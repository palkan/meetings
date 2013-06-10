package ru.teachbase.traits
{
import ru.teachbase.events.LocalStreamEvent;
import ru.teachbase.model.LocalStream;
import ru.teachbase.model.Packet;
import ru.teachbase.model.constants.PacketType;

public class LocalStreamTrait extends Trait
	{
    [Event(name="", type="ru.teachbase.events.LocalStreamEvent")]
		public function LocalStreamTrait()
		{
			super(PacketType.I_VIDEO,true);
			_readyToReceive = true;
		}
		
		override protected function prepareInput(data:Object):Object{
			
			if(!(data is Packet)) return null;
			
			var p:Packet = data as Packet;
			
			if(!(p.data is LocalStream)) return null;
			
			return (p.data as LocalStream); 
			
		}
		
		override protected function dispatchTraitEvent(data:Object):void{
				
			dispatchEvent(new LocalStreamEvent(LocalStreamEvent.VIDEO_CHANGED, data as LocalStream));
			
		}
	}
}