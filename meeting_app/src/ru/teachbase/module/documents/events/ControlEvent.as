package ru.teachbase.module.documents.events
{
import flash.events.Event;

public class ControlEvent extends Event
	{
		
		public static const CHANGE:String = "change_in_doc";
		
		
		private var _method:String;
		
		
		private var _args:Array;
		
		
		private var _callServer:Boolean;
		
		
				
		private var _handler:uint;
		
		public function ControlEvent(type:String, method:String, args:Array = null, callServer:Boolean = false, handler:uint = 1, bubbles:Boolean = false)
		{
			super(type, bubbles);
			_method = method;
			_args = args;
			_callServer = callServer;
			_handler = handler;
		}


		/**
		 * Name of the hanlder method
		 * 
		 */
		public function get method():String
		{
			return _method;
		}

		/**
		 * @private
		 */
		public function set method(value:String):void
		{
			_method = value;
		}

		/**
		 * Arguments to pass to the method
		 * 
		 */
		public function get args():Array
		{
			return _args;
		}

		/**
		 * @private
		 */
		public function set args(value:Array):void
		{
			_args = value;
		}

		/**
		 * If <i>true</i> then dispath to server
		 */
		public function get callServer():Boolean
		{
			return _callServer;
		}

		/**
		 * @private
		 */
		public function set callServer(value:Boolean):void
		{
			_callServer = value;
		}

		/**
		 * 
		 * Bitmask of host component of a method. First bit indicates if renderer handle this method, second - the same about container
		 * 
		 */
		public function get handler():uint
		{
			return _handler;
		}

		/**
		 * @private
		 */
		public function set handler(value:uint):void
		{
			_handler = value;
		}


	}
}