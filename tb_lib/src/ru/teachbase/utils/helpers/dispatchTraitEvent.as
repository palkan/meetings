package ru.teachbase.utils.helpers
{
import ru.teachbase.events.TraitEvent;
import ru.teachbase.manage.TraitManager;
import ru.teachbase.model.Packet;

/**
	 *  Dispatch local TraitEvent.
	 * 
	 * @param type Type of the packet
	 * @param value Packet data 
	 * 
	 */
	public function dispatchTraitEvent(type:String,value:*):void
	{
		
		TraitManager.instance.dispatchEvent(
			new TraitEvent(
				type,
				new Packet(type,value)
			)
		);
		
	}
	
}