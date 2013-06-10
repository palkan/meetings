package ru.teachbase.traits
{
import ru.teachbase.events.StreamEvent;
import ru.teachbase.model.Packet;
import ru.teachbase.model.Stream;
import ru.teachbase.model.constants.PacketType;

/**
	 * @author Webils (created: May 14, 2012)
	 */
	public final class StreamTrait extends Trait
	{
		[Event(name="stream", type="ru.teachbase.events.StreamEvent")]
		//------------ constructor ------------//
		
		public function StreamTrait()
		{
			super(PacketType.STREAM, true);
		}
		
		override protected function prepareInput(data:Object):Object {
			if (!(data is Packet)) return null;
				
			var p:Packet = data as Packet;
			if (!(p.data is Stream)){ return null};
			
			return p.data as Stream; 
			
		}		
		
		override protected function dispatchTraitEvent(data:Object):void{
			
			if(data && (data as Stream).name == "")
				dispatchEvent(new StreamEvent(StreamEvent.STREAM_CHANGE, data as Stream));
			else		
				dispatchEvent(new StreamEvent(StreamEvent.STREAM, data as Stream));
			
			
		}
		//------------ initialize ------------//
		
		//--------------- ctrl ---------------//
		
		//------------ get / set -------------//
		
		//------- handlers / callbacks -------//
		
	}
}