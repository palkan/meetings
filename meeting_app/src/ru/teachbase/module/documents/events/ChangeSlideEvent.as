package ru.teachbase.module.documents.events
{
import flash.events.Event;

public class ChangeSlideEvent extends Event
	{
		
		public static var DIRECTION_LEFT:String = "direction_left";
		public static var DIRECTION_RIGHT:String = "direction_right";
		public static var DIRECTION_DIRECT:String = "direction_direct";
		
		private var _direction:String;
		private var _slideId:int = 0;
		private var _rotation:Number = 0;
		private var _zoom:Number = 0;
		
		public function ChangeSlideEvent(type:String, direction:String, slideId:int = 0, rotation:Number = 0, zoom:Number = 0)
		{
			super(type, true);
			_direction = direction
			_slideId = slideId; 
			_rotation = rotation;
			_zoom = zoom;
		}
		
		public function get direction():String{
			return _direction;
		}
		
		public function get slideId():int {
			return _slideId;
		}

		public function get rotation():Number
		{
			return _rotation;
		}

		public function get zoom():Number
		{
			return _zoom;
		}

		
	}
}