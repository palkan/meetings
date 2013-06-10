package ru.teachbase.utils
{
import flash.errors.IllegalOperationError;

import ru.teachbase.core.App;
import ru.teachbase.events.TraitEvent;
import ru.teachbase.model.Packet;
import ru.teachbase.model.constants.PacketType;

public final class GlobalError
	{
		
		
		private static const instance:GlobalError = new GlobalError();
		
		public function GlobalError()
		{
			if(instance)
				throw new IllegalOperationError('Localizer is a sinlegton');
		}
		
		
		public static function raise(message:String):void{
			
			App.traitManager.dispatchEvent(new TraitEvent(PacketType.STATE, new Packet(PacketType.STATE,{level:"error",text:message})));
			
		}
		
		
	}
}