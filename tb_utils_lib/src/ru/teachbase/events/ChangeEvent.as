package ru.teachbase.events
{
import flash.events.Event;

/**
	 * @author Teachbase (created: May 11, 2012)
	 */
	public final class ChangeEvent extends Event
	{
		public static const CHANGED:String = "tb:changed";
		
		private var _host:Object;
		private var _property:String;
		private var _value:*;
		private var _oldValue:*;
		
		//------------ constructor ------------//
		
		public function ChangeEvent(host:Object, property:String, newValue:*, oldValue:* = null, bubbles:Boolean = false, cancelable:Boolean = false)
		{
			super(CHANGED, bubbles, cancelable);
			_host = host;
			_property = property;
			_value = newValue;
			_oldValue = oldValue;
		}
		
		//------------ initialize ------------//
		
		//--------------- ctrl ---------------//
		
		//------------ get / set -------------//
		
		public function get host():Object
		{
			return _host;
		}
		
		public function get property():String
		{
			return _property;
		}
		
		public function get value():*
		{
			return _value;
		}
		
		public function get oldValue():*
		{
			return _oldValue;
		}
		
		//------- handlers / callbacks -------//
	}
}