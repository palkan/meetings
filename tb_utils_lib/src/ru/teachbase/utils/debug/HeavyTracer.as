package ru.teachbase.utils.debug
{
import flash.errors.IllegalOperationError;
import flash.trace.Trace;

/**
	 * @author Teachbase (created: Feb 13, 2012)
	 */
	public final class HeavyTracer
	{
		private static const ignore:Vector.<String> = new <String>['flash.trace', 'flash.utils', 'flash.events', 'flashx.textLayout', 'caurina', 'spark', 'mx.'];
		public static const instance:HeavyTracer = new HeavyTracer();
		
		//------------ constructor ------------//
		
		public function HeavyTracer()
		{
			if(instance)
				throw new IllegalOperationError(this + ' I\'m an Singleton.');
			
			trace('HeavyTracer initialize');
		}
		
		//------------ initialize ------------//
		
		//--------------- ctrl ---------------//
		
		public function on():void
		{
			Trace.setLevel(Trace.METHODS_AND_LINES_WITH_ARGS, Trace.LISTENER);
			Trace.setListener(callback);
		}
		
		public function off():void
		{
			Trace.setLevel(Trace.METHODS_AND_LINES_WITH_ARGS, Trace.OFF);
			//Trace.setListener(null);
		}
		
		
		//------------ get / set -------------//
		
		//------- handlers / callbacks -------//
		
		private function callback(fqcn:String, lineNumber:uint, methodName:String, methodArguments:*):void
		{
			//Trace.setLevel(Trace.METHODS_AND_LINES_WITH_ARGS, Trace.OFF);
			for(var i:int; i < ignore.length; ++i)
			{
				if(methodName.indexOf(ignore[i]) === 0)
					return;// trace('!', methodName);
			}
			
			trace('>>', lineNumber, methodName, methodArguments, '\n\t', fqcn);
			
			//Trace.setLevel(Trace.METHODS_AND_LINES_WITH_ARGS, Trace.LISTENER);
		}
	}
}