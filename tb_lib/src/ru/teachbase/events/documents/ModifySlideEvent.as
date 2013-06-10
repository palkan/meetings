package ru.teachbase.events.documents
{
import flash.events.Event;

public class ModifySlideEvent extends Event
	{

		public static const ROTATE:String = "rotate";
		public static const ZOOM_IN:String = "zoom_in";
		public static const ZOOM_OUT:String = "zoom_out";
		
		private var _action:String;
		
		public function ModifySlideEvent(type:String, value:String)
		{
			super(type);
			_action = value;
		}
		
		public function get action():String{
			return _action;
		}
	}
}