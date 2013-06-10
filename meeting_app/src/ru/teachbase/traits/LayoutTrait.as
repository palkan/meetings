package ru.teachbase.traits
{
import ru.teachbase.manage.layout.events.LayoutEvent;
import ru.teachbase.manage.layout.model.LayoutChangeData;
import ru.teachbase.model.Packet;
import ru.teachbase.constants.PacketType;

[Event(name="change", type="ru.teachbase.manage.layout.events.LayoutEvent")]
	
	[Event(name="switch", type="ru.teachbase.manage.layout.events.LayoutEvent")]

	public class LayoutTrait extends RTMPListener
	{
		public function LayoutTrait()
		{
			super(PacketType.LAYOUT);
		}
		
		
		override protected function prepareOutputData(data:Object):Object{
			
			var _d:LayoutChangeData = new LayoutChangeData();
			_d.fromObject(data);
			
			return _d;
			
		}
		
		
		override protected function prepareInput(data:Object):Object{
			
			if(!(data is Packet)) return null;
			
			var p:Packet = data as Packet;
			
			if(!(p.data is LayoutChangeData)) return null;
			
			return (p.data as LayoutChangeData); 
			
		}
		
		
		
		override protected function dispatchTraitEvent(data:Object):void{
			
			
			dispatchEvent(new LayoutEvent(LayoutEvent.CHANGE, data as LayoutChangeData));
			
			
		}
		
		
	}
}