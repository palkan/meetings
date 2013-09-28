package ru.teachbase.behaviours
{

import flash.events.EventDispatcher;

import ru.teachbase.utils.interfaces.IDisposable;

/**
	 * Base abstract class for all behaviors.
	 * @author Teachbase (created: Jan 24, 2012)
	 */
	public class Behavior extends EventDispatcher implements IDisposable
	{
		private var _initialized:Boolean;
		private var _disposed:Boolean;
		
		//------------ constructor ------------//
		
		public function Behavior()
		{
			super();
		}
		
		//------------ initialize ------------//
		
		protected function initialize():void
		{
			_initialized = true;
			_disposed = false;
		}
		
		public function dispose():void
		{
			_disposed = true;
			_initialized = false;
		}
		
		//--------------- ctrl ---------------//
		
		//------------ get / set -------------//
		
		protected function get initialized():Boolean
		{
			return _initialized;
		}
		
		public function get disposed():Boolean
		{
			return _disposed;
		}
		
		//------- handlers / callbacks -------//
		
	}
}