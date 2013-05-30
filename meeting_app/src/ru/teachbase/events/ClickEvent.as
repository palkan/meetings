package ru.teachbase.events
{
import flash.events.Event;

public class ClickEvent extends Event
	{
		public static var TYPE:String = "clickEvent";
		
		private var _id:String;
		public function ClickEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false, objId:String = "0")
		{
			super(type, bubbles, cancelable);
			_id = objId;
		}
		
		public function get objId():String {
			return _id;
		}
		
		override public function clone():Event {
			return new ClickEvent(type, bubbles, cancelable, _id);
		}
	}
}