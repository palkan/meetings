package ru.teachbase.events
{
import flash.events.Event;

public class TreeEvent extends Event
	{
		
		public static const ITEM_CLOSE:String = "itemClose";
		
		public static const ITEM_OPEN:String = "itemOpen";
		
		private var _clickedTarget:Object;
		
		public function TreeEvent (type:String, bubbles:Boolean, obj:Object)
		{
			super(type,bubbles,false);
			_clickedTarget = obj;
		}

		public function get clickedTarget():Object
		{
			return _clickedTarget;
		}

	}
}