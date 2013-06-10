package ru.teachbase.events
{
import flash.errors.IllegalOperationError;
import flash.events.EventDispatcher;

internal final class GlobalEventDispatcher extends EventDispatcher
	{
		tb_events static const instance:GlobalEventDispatcher = new GlobalEventDispatcher();
				
		public function GlobalEventDispatcher()
		{
			
			if(tb_events::instance)
				throw new IllegalOperationError("Singleton Error. GlobalEventDispatcher");
			
		}
		
	}
}