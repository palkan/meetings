package ru.teachbase.events
{
import flash.events.Event;
import flash.media.Camera;

public class CameraEvent extends Event
	{
		
		public static const CAMERA_CHANGED:String = "camera_changed";
		public static const CAMERA_END:String = "camera_end";
		
		public var _camera:Camera;
		
		public function CameraEvent(type:String, camera:Camera = null, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			_camera = camera;
		}
		
		public function get camera():Camera{
			return _camera;
		}
	}
}