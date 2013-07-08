package ru.teachbase.events
{
import flash.events.Event;

    /**
	 *
     * General change event class with the only one Event type.
     *
	 */
	public final class ChangeEvent extends Event
	{
        /**
         * @eventType tb:changed
         */

		public static const CHANGED:String = "tb:changed";
		
		private var _host:Object;
		private var _property:String;
		private var _value:*;
		private var _oldValue:*;


        /**
         *
         * Create new ChangeEvent
         *
         * @param host
         * @param property
         * @param newValue
         * @param oldValue
         * @param bubbles
         * @param cancelable
         */

		public function ChangeEvent(host:Object, property:String, newValue:*, oldValue:* = null, bubbles:Boolean = false, cancelable:Boolean = false)
		{
			super(CHANGED, bubbles, cancelable);
			_host = host;
			_property = property;
			_value = newValue;
			_oldValue = oldValue;
		}


        /**
         * Event dispatcher object
         */

		public function get host():Object
		{
			return _host;
		}


        /**
         * Name of the changed property
         */

		public function get property():String
		{
			return _property;
		}


        /**
         *
         * Changed property new value
         */

		public function get value():*
		{
			return _value;
		}


        /**
         *
         * Changed property old value
         *
         */

		public function get oldValue():*
		{
			return _oldValue;
		}
		
	}
}