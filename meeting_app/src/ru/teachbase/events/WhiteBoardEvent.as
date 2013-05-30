package ru.teachbase.events
{
import flash.events.Event;

public class WhiteBoardEvent extends Event
	{
		
		public static const TOOL:String = "tool";
		public static const PROPERTY:String = "property";
		public static const UNDOREDO:String = "undo_redo";
		public static const CHANGE:String = "change";
		
		
		private var _oldValue:*;
		private var _value:*;
		private var _propertyId:String;
		private var _propertyIndex:uint;
		
		public function WhiteBoardEvent(type:String, value:* = null, old:* = null, propertyId:String = "", bubbles:Boolean=true, cancelable:Boolean=true)
		{
			//TODO: implement function
			super(type, bubbles, cancelable);
			_value = value;
			_oldValue = old;
			_propertyId = propertyId;
			
		}

		public function get oldValue():*
		{
			return _oldValue;
		}

		public function get value():*
		{
			return _value;
		}

		public function get propertyId():String
		{
			return _propertyId;
		}

		public function get propertyIndex():uint
		{
			return _propertyIndex;
		}


	}
}