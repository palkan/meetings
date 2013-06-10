package ru.teachbase.traits
{
import ru.teachbase.module.board.events.WhiteBoardEvent;
import ru.teachbase.model.Packet;
import ru.teachbase.constants.PacketType;

[Event(name="change", type="ru.teachbase.module.board.events.WhiteBoardEvent")]
	
	public class BoardTrait extends RTMPListener
	{
		public function BoardTrait(id:int)
		{
			super(PacketType.WHITEBOARD, true);
			
			_instanceId = id;
		}
		
		
		override protected function prepareInput(data:Object):Object{
			
			if(!(data is Packet)) return null;
			
			var p:Packet = data as Packet;
			
			if(p.minstance != _instanceId) return null;
			
			return p.data; 
			
		}
		
		
		override protected function dispatchTraitEvent(data:Object):void{
			
			
				dispatchEvent(new WhiteBoardEvent(WhiteBoardEvent.CHANGE, data));
			}
		
		
	}
}