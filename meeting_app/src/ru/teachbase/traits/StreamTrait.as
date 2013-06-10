package ru.teachbase.traits
{
import ru.teachbase.manage.streams.events.StreamEvent;
import ru.teachbase.model.Packet;
import ru.teachbase.manage.streams.model.StreamData;
import ru.teachbase.constants.PacketType;

/**
	 * @author Webils (created: May 14, 2012)
	 */
	public final class StreamTrait extends RTMPListener
	{
		[Event(name="stream", type="ru.teachbase.manage.streams.events.StreamEvent")]
		//------------ constructor ------------//
		
		public function StreamTrait()
		{
			super(PacketType.STREAM, true);
		}
		
		override protected function prepareInput(data:Object):Object {
			if (!(data is Packet)) return null;
				
			var p:Packet = data as Packet;
			if (!(p.data is StreamData)){ return null};
			
			return p.data as StreamData;
			
		}		
		
		override protected function dispatchTraitEvent(data:Object):void{
			
			if(data && (data as StreamData).name == "")
				dispatchEvent(new StreamEvent(StreamEvent.STREAM_CHANGE, data as StreamData));
			else		
				dispatchEvent(new StreamEvent(StreamEvent.STREAM, data as StreamData));
			
			
		}
		//------------ initialize ------------//
		
		//--------------- ctrl ---------------//
		
		//------------ get / set -------------//
		
		//------- handlers / callbacks -------//
		
	}
}