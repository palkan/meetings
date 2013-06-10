package ru.teachbase.traits
{
import flash.events.ErrorEvent;
import flash.events.Event;

import ru.teachbase.events.FileStatusEvent;
import ru.teachbase.model.Packet;
import ru.teachbase.constants.PacketType;

[Event(name="progress", type="flash.events.ProgressEvent")]
	[Event(name="error", type="flash.events.ErrorEvent")]
	[Event(name="start", type="ru.teachbase.events.FileStatusEvent")]
	[Event(name="complete", type="flash.events.Event")]
	
	public class FileTrait extends RTMPListener
	{
		public function FileTrait()
		{
			super(PacketType.FILE, true);
			_readyToReceive = true;
		}
	
	
	
	override protected function prepareInput(data:Object):Object{
		
		if(!(data is Packet)) return null;
		
		var p:Packet = data as Packet;
				
		return p.data; 
		
	}
	
	
	override protected function dispatchTraitEvent(data:Object):void{
		switch(data.status){
			case "error":
			{
				dispatchEvent(new ErrorEvent(ErrorEvent.ERROR,false,false,data.error));
				break;
			}
				
			case "start":
			{
				dispatchEvent(new FileStatusEvent(FileStatusEvent.START,data.id));
				break;
			}
				
			case "progress":
			{
				
				dispatchEvent(new FileStatusEvent(FileStatusEvent.PROGRESS,data.progress));
				break;
			}
				
			case "complete":
			{
				dispatchEvent(new Event(Event.COMPLETE));	
				break;
			}	
		}
	}
	}
}