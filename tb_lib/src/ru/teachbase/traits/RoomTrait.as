package ru.teachbase.traits
{
import ru.teachbase.events.RoomEvent;
import ru.teachbase.model.Packet;
import ru.teachbase.model.constants.PacketType;

[Event(name="users_changed", type="ru.teachbase.events.RoomEvent")]
	
	public class RoomTrait extends Trait
	{
		public function RoomTrait()
		{
			super(PacketType.ROOM_CHANGES);
		}
		
		
		override protected function prepareInput(data:Object):Object{
			
			if(!(data is Packet)) return null;
			
			var p:Packet = data as Packet;
			
			return p.data; 
			
		}
		
		
		
		override protected function dispatchTraitEvent(data:Object):void{
			
			
			dispatchEvent(new RoomEvent(RoomEvent.USERS_CHANGED, data));
			
			
		}
	}
}