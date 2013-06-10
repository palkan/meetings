package ru.teachbase.traits
{
import ru.teachbase.manage.session.events.MeetingEvent;
import ru.teachbase.model.Packet;
import ru.teachbase.constants.PacketType;

[Event(name="users_changed", type="ru.teachbase.manage.session.events.MeetingEvent")]
	
	public class RoomTrait extends RTMPListener
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
			
			
			dispatchEvent(new MeetingEvent(MeetingEvent.USERS_CHANGED, data));
			
			
		}
	}
}