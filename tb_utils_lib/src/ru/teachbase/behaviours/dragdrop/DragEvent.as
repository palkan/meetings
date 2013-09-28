package ru.teachbase.behaviours.dragdrop
{
import flash.events.Event;
import flash.geom.Point;

/**
	 * @author Teachbase (created: Jan 30, 2012)
	 */
	public final class DragEvent extends Event
	{
		public static const DRAG_PREPARE:String = "dragPrepare";
		public static const DRAG_START:String = "dragStart";
		public static const DRAG_CANCEL:String = "dragCancel";
		
		/**
		 * Identical to the <b>end of drag</b>.
		 */		
		public static const DRAG_END:String = "dragEnd";
		public static const DRAG_DROP:String = "dragDrop";
		
		//--- links / state:
		private var _startMouse:Point;
		private var _lastMouse:Point;
		private var _startDraggle:Point;
		private var _lastDraggle:Point;
		private var _direction:uint;
		private var _canceled:Boolean;
		
		
		//------------ constructor ------------//
		
		public function DragEvent(type:String, startMouse:Point, lastMouse:Point, startDraggle:Point, lastDraggle:Point, direction:uint = 0, canceled:Boolean = false, bubbles:Boolean = false)
		{
			super(type, bubbles, true);
			_startMouse = startMouse,
			_lastMouse = lastMouse,
			_lastDraggle = lastDraggle,
			_startDraggle = startDraggle;
			_direction = direction;
			_canceled = canceled;
		}
		
		//------------ initialize ------------//
		
		//--------------- ctrl ---------------//
		
		override public function toString():String
		{
			return '[DragEvent type="' + type + '" mouse=' + _startMouse + '->' + _lastMouse + ' draggle=' + _startDraggle + '->' + _lastDraggle + ' direction=' + _direction + ' eventPhase=2]';
		}
		
		//------------ get / set -------------//
		
		public function get startMouse():Point
		{
			return _startMouse;
		}
		
		public function get lastMouse():Point
		{
			return _lastMouse;
		}
		
		public function get startDraggle():Point
		{
			return _startDraggle;
		}
		
		public function get lastDraggle():Point
		{
			return _lastDraggle;
		}
		
		public function get direction():uint
		{
			return _direction;
		}
		
		public function get canceled():Boolean
		{
			return _canceled;
		}
		
		//------- handlers / callbacks -------//
	}
}