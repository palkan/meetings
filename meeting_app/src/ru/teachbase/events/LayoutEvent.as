package ru.teachbase.events
{


import flash.events.Event;

import ru.teachbase.model.LayoutChangeData;

public class LayoutEvent extends Event
	{
		public static const CHANGE:String = "change";
		public static const SWITCH:String = "switch";
		
		private var _data:LayoutChangeData;
		
		public function LayoutEvent(type:String, data:LayoutChangeData = null, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			_data = data;
		}

		public function get data():LayoutChangeData
		{
			return _data;
		}

	}
}