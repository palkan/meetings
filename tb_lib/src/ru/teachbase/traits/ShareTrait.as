package ru.teachbase.traits
{
import ru.teachbase.core.App;
import ru.teachbase.events.ShareEvent;
import ru.teachbase.model.Packet;
import ru.teachbase.model.constants.PacketType;

[Event(name="stop_sharing", type="ru.teachbase.events.ShareEvent")]
		
	public class ShareTrait extends Trait
	{
		
		private var _status:uint = 0;
		
		public function ShareTrait()
		{
			super(PacketType.SHARING);
			_readyToReceive = true;
		}
		
		
		override protected function dispatchTraitEvent(data:Object):void{
			
			dispatchEvent(new ShareEvent(ShareEvent.STOP_SHARING,data));
	
		}
		
		
		override protected function prepareInput(data:Object):Object{
			
			if(!(data is Packet)) return null;
			
			return (data as Packet).data;
			
			
		}

		public function set status(value:uint):void
		{
			_status = value;
			App.room.user && this.call("stream_status", null, App.room.user.sid, value);
			
		}	
		
	}
}