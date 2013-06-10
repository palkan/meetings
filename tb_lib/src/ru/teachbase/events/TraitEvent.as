package ru.teachbase.events
{
import flash.events.Event;

import ru.teachbase.model.Packet;
import ru.teachbase.traits.__trait;

public class TraitEvent extends Event
	{
			
		private var _target:Object;
		private var _packet:Packet;
		
	//------------ constructor ------------//
		
		public function TraitEvent(type:String, packet:Packet, target:Object = null, cancelable:Boolean = false, bubbles:Boolean = false)
		{
			super(type, bubbles, cancelable);
			_packet = packet;
			_target = target;
		}
		
		//------------ initialize ------------//
		
		//--------------- ctrl ---------------//
		
		
		public function get packet():Packet
		{
			return _packet;
		}
		
		__trait function set target(value:Object):void
		{
			_target = value;
		}
		
		//------- handlers / callbacks -------//
		
	}
}