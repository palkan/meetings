package ru.teachbase.manage.layout.events
{


import flash.events.Event;

import ru.teachbase.manage.layout.model.LayoutChangeData;

public class LayoutEvent extends Event
	{
		public static const CHANGE:String = "tb:layout_change";
        public static const LOCK:String = "tb:layout_lock";

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