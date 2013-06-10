package ru.teachbase.traits
{
import ru.teachbase.events.PermissionEvent;
import ru.teachbase.model.Packet;
import ru.teachbase.constants.PacketType;

[Event(name="permissions", type="ru.teachbase.events.PermissionEvent")]
	
	
	public class PermissionTrait extends RTMPListener
	{
		public function PermissionTrait()
		{
			super(PacketType.PERMISSSON,true);
			_readyToReceive = true;
		}
		
		override protected function prepareInput(data:Object):Object{
			
			if(!(data is Packet)) return null;
			
			var p:Packet = data as Packet;
			
			return p.data; 
			
		}
		
		
		override protected function dispatchTraitEvent(data:Object):void{
			
			
			dispatchEvent(new PermissionEvent(PermissionEvent.PERMISSIONS_CHANGED, data));
			
			
		}
		
	}
}