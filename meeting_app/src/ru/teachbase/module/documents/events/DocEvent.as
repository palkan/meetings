package ru.teachbase.module.documents.events
{
import flash.events.Event;

import ru.teachbase.module.documents.model.WorkplaceData;

public class DocEvent extends Event
	{
		
		
		public static const CHANGE:String = "change";
		public static const STATE:String = "state";
		public static const LOAD:String = "load";
		
		private var _data:WorkplaceData;
		
		public function DocEvent(type:String, data:WorkplaceData, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			_data = data;
			
		}

		public function get data():WorkplaceData
		{
			return _data;
		}
	
	}
}