package ru.teachbase.module.documents.events
{
import flash.events.Event;

public class SliderEvent extends Event
	{
		
		public static const SLIDER_VALUE_CHANGED:String = 'slider_value_changed';
		
		private var _position:Number;
		
		public function SliderEvent(type:String, pos:Number, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			_position = pos;
		}
		
		
		public function get position():Number
		{
			return _position;
		}

	}
}