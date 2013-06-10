package ru.teachbase.traits
{
import ru.teachbase.events.NotificationEvent;
import ru.teachbase.model.Notification;
import ru.teachbase.model.Packet;
import ru.teachbase.model.constants.PacketType;

public class NotificationTrait extends Trait
	{
        public function NotificationTrait()
		{
			super(PacketType.NOTIFICATION, true);
			_readyToReceive = true;
		}
		
		override protected function prepareInput(data:Object):Object{
			
			if(!(data is Packet)) return null;
			
			var p:Packet = data as Packet;
			
			if(!(p.data is Notification)) return null;
			
			return (p.data as Notification); 
			
		}
		
		override protected function dispatchTraitEvent(data:Object):void{
			
			dispatchEvent(new NotificationEvent(NotificationEvent.NOTIFICATION_EVENT , data as Notification));
			
		}

	}
}