package ru.teachbase.events
{
import flash.errors.IllegalOperationError;
import flash.events.EventDispatcher;

internal final class GlobalEventDispatcher extends EventDispatcher
	{
		__tbevents static const instance:GlobalEventDispatcher = new GlobalEventDispatcher();
				
		public function GlobalEventDispatcher()
		{
			
			if(__tbevents::instance)				
				throw new IllegalOperationError("Singleton Error. GlobalEventDispatcher");
			
		}
		
	}
}