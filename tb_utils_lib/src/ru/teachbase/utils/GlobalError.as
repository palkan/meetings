package ru.teachbase.utils
{

import flash.events.ErrorEvent;
import flash.events.EventDispatcher;

import ru.teachbase.error.SingletonError;
import ru.teachbase.events.ErrorCodeEvent;


public final class GlobalError extends EventDispatcher
	{
		private static const instance:GlobalError = new GlobalError();
		
		public function GlobalError()
		{
			if(instance)
				throw new SingletonError();
		}


        public static function listen(callback:Function):void{
            instance.addEventListener(ErrorEvent.ERROR,callback);
        }

        public static function unlisten(callback:Function):void{
            instance.removeEventListener(ErrorEvent.ERROR,callback);
        }
		
		
		public static function raise(message:String, code:uint = 0):void{
			
			instance.dispatchEvent(new ErrorCodeEvent(ErrorEvent.ERROR,false,false,message, code));
			
		}
		
		
	}
}