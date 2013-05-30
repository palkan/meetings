package ru.teachbase.events.documents
{
import flash.events.Event;
import flash.geom.Point;

public class MoveEvent extends Event
	{
		private var _point:Point;
		
		public function MoveEvent(type:String, value:Point)
		{
			super(type,true);
			_point = value;
		}
		
		public function get point():Point{
			return _point;
		}
	}
}