package ru.teachbase.traits
{
import ru.teachbase.module.screenshare.events.ScreenShareEvent;
import ru.teachbase.model.Packet;
import ru.teachbase.constants.PacketType;

[Event(name="tb_ss_start", type="ru.teachbase.module.screenshare.events.ScreenShareEvent")]
	[Event(name="tb_ss_stop", type="ru.teachbase.module.screenshare.events.ScreenShareEvent")]
	[Event(name="tb_ss_prepare", type="ru.teachbase.module.screenshare.events.ScreenShareEvent")]
	
	public class ScrShareTrait extends RTMPListener
	{
		public function ScrShareTrait()
		{
			super(PacketType.SCREEN_SHARING, true);
		}
		
		
		override protected function prepareInput(data:Object):Object{
			
			if(!(data is Packet)) return null;
			
			var p:Packet = data as Packet;
			
			return p.data; 
			
		}
		
		
		
		override protected function dispatchTraitEvent(data:Object):void{
			
			if(data.type === "prepare")
				dispatchEvent(new ScreenShareEvent(ScreenShareEvent.PREPARE_SHARE,Number(data.uid)));
			else if(data.type === "start")
				dispatchEvent(new ScreenShareEvent(ScreenShareEvent.START_SHARE,Number(data.uid), data.stream));
			else if(data.type === "stop")
				dispatchEvent(new ScreenShareEvent(ScreenShareEvent.STOP_SHARE));
			
			
		}
		
	}
}