package ru.teachbase.traits
{
import flash.media.Camera;

import ru.teachbase.events.CameraEvent;
import ru.teachbase.model.Packet;
import ru.teachbase.model.constants.PacketType;

[Event(name="video_changed", type="ru.teachbase.events.CameraEvent")]
	
	public class CameraTrait extends Trait
	{
		public function CameraTrait()
		{
			super(PacketType.I_CAMERA,true);
			_readyToReceive = true;
		}
		
		override protected function prepareInput(data:Object):Object{
			
			if(!(data is Packet)) return null;
			
			var p:Packet = data as Packet;
			if ((p.data is Camera)){ 
				dispatchEvent(new CameraEvent(CameraEvent.CAMERA_CHANGED, p.data as Camera));
			}else{
				dispatchEvent(new CameraEvent(CameraEvent.CAMERA_END, null));
			}
				
			return null; // prevent dispach event from superclass
			
		}

	}
}