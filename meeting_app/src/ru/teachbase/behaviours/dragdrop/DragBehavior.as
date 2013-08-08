package ru.teachbase.behaviours.dragdrop
{
import ru.teachbase.behaviours.*;

import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.ui.Mouse;
import flash.ui.MouseCursor;
import flash.utils.getTimer;

import mx.core.EventPriority;

import ru.teachbase.behaviours.interfaces.IDragCoordinateSpace;
import ru.teachbase.behaviours.interfaces.INotDraggle;
import ru.teachbase.behaviours.dragdrop.DragEvent;

import ru.teachbase.behaviours.dragdrop.tb_drag;

import ru.teachbase.utils.geom.angleAB;
import ru.teachbase.utils.shortcuts.debug;

[Event(name="dragPrepare", type="ru.teachbase.behaviours.dragdrop.DragEvent")]
	[Event(name="dragStart", type="ru.teachbase.behaviours.dragdrop.DragEvent")]
	[Event(name="dragCancel", type="ru.teachbase.behaviours.dragdrop.DragEvent")]
	[Event(name="dragEnd", type="ru.teachbase.behaviours.dragdrop.DragEvent")]

	
	/**
	 * @author Teachbase (created: Jan 25, 2012)
	 */
	
	public class DragBehavior extends InteractiveBehavior
	{
		//--- links:
		private static var _currentDragBehavior:DragBehavior;
		private static const _pretenders:Vector.<DragBehavior> = new Vector.<DragBehavior>();
		public var priority:int = 0;
		
		private var _active:Boolean = true;
		
		//--- properties:
		
		/**
		 * Allowed direction for drag.
		 */		
		public var direction:uint = DragDirection.NO_DIRECTION;
		
		/**
		 * Allowed direction for start drag (prepare-state).
		 */		
		public var startDirection:uint = DragDirection.ANY;
		
		/**
		 * Necessary shift of mouse cursor or finger for start drag.
		 */		
		public var startShiftDistance:uint = 2;
		
		/**
		 * Bounds of draggable zone.
		 * <br/>
		 * If <code>null</code> then bounds will not track as infinity.
		 */		
		public var bounds:IDragCoordinateSpace;// = new BoundsClass();
		
		/**
		 * Bounds of draggable zone (not assigned to any display object).
		 * <br/>
		 * Use only with virtual layouts.
		 */
		
		public var virtualBounds:Rectangle;
		
		/**
		 * Before calling the constructor creates an instance of this class <code>BoundsClass</code> in the variable <code>bounds</code>.
		 */		
		public static var BoundsClass:Class = DragCoordinateSpace;
		
		/**
		 * Break dragging if mouse leaves drag-bounds.
		 */		
		public var breakAfterLeaveBounds:Boolean;
		
		/**
		 * Define whether to check if there exists INotDraggle parent 
		 */
		public var considerParent:Boolean = true;
		
		public var mouseCoordinateSpace:DisplayObject;
		private var _mouseCoordinateSpaceCurrent:DisplayObject;
		
		/**
		 * Frequency of direction detection.
		 * <br/>
		 * 0 or 1 = every move.
		 */		
		public var mouseRecogniseEvery:uint = 2;
		private var mouseRecogniseCount:uint = 0;
		
		//--- state:
		
		private var _state:String = '';
		
		private var _currentDraggleDirection:uint = DragDirection.NO_DIRECTION;
		private var _currentMouseDirection:uint = DragDirection.NO_DIRECTION;
		protected var needRecogniseDraggleDirection:Boolean;
		protected var needRecogniseMouseDirection:Boolean;
		private var _dragging:Boolean;
		
		private var _dragPrepareTime:int;
		private var _prepareDispatchTime:int;
		
		private const _startMouse:Point = new Point(NaN, NaN);
		private const _lastMouse:Point = new Point(NaN, NaN);
		private const _startDraggle:Point = new Point(NaN, NaN);
		private const _lastDraggle:Point = new Point(NaN, NaN);
		
		private var _useCapture:Boolean = true;
        private var lastDispatchedEventType:String;
		
		//------------ constructor ------------//
		
		public function DragBehavior()
		{
			super();
		}
		
		//------------ initialize ------------//
		
		override protected function initialize():void
		{
			super.initialize();
			
			if(!draggle || !stage)
				return;
			
			// add event-listeners:
			addListeners();
			
		}
		
		private function addListeners():void
		{
			if(!_active || !target || !stage) return;
			target.addEventListener(MouseEvent.MOUSE_DOWN, downHandler, _useCapture, EventPriority.CURSOR_MANAGEMENT);
			stage.addEventListener(MouseEvent.MOUSE_UP, upHandler, _useCapture, EventPriority.CURSOR_MANAGEMENT);
			
		}
		
		private function removeListeners():void
		{
			if(!target || !stage) return;
			target.removeEventListener(MouseEvent.MOUSE_DOWN, downHandler, _useCapture);
			stage.removeEventListener(MouseEvent.MOUSE_UP, upHandler, _useCapture);
			
		}
		
		override public function dispose():void
		{
			removeListeners();
			
			upHandler();
			
			bounds && bounds.dispose();
			
			super.dispose();
		}
		
		//--------- static pretenders ---------//
		
		protected static function addPretender(value:DragBehavior):void
		{
			// test
			if(_pretenders.indexOf(value) !== -1)
				return;
			
			// add
			_pretenders.push(value);
		}
		
		protected static function removePretender(value:DragBehavior):void
		{
			const index:int = _pretenders.indexOf(value);
			// test
			if(index !== -1)
				return;
			
			// remove
			_pretenders.splice(index, 1);
		}


        /**
         *
         * Cancel dragging parents
         *
         * @param futured
         */
		
		protected static function cancelParentalPretenders(futured:DragBehavior):void
		{
			for(var i:int; i < _pretenders.length; ++i)
			{
				if(futured._target !== _pretenders[i]._target
					&& _pretenders[i]._target is DisplayObjectContainer && futured._target is DisplayObjectContainer
					&& (_pretenders[i]._target as DisplayObjectContainer).contains(futured._target))
				{
					_pretenders[i].cancel(false);
				}
			}
		}
		
		
		
		protected static function hasParent(child:DisplayObject, Type:Class):Boolean
		{
			if(child && ('parent' in child) && child.parent)
				return (child.parent is Type) || hasParent(child.parent, Type);
			return false;
		}
		
		protected static function hasParentSpecial(child:DisplayObject, parentRequired:DisplayObjectContainer):Boolean
		{
			if(child && parentRequired && ('parent' in child) && child.parent)
				return child.parent === parentRequired || hasParentSpecial(child.parent, parentRequired);
			return false;
		}
		
		
		
		//--------------- ctrl ---------------//
		
		protected function startDrag():void
		{
			if(_dragging)
				return;
			
			_dragging = true;
			_currentDragBehavior = this;
			tb_drag::state = DragState.DRAGGING;
			
			const bounds:Rectangle = calculateDragBounds();
			
			_startDraggle.x = _lastDraggle.x = draggle.x;
			_startDraggle.y = _lastDraggle.y = draggle.y;
			
			Mouse.cursor = MouseCursor.HAND;
			draggle.startDrag(false, bounds);
			
			smartDispatchEvent(DragEvent.DRAG_START);
		}
		
		protected function stopDrag():void
		{
			// anyway:
			removePretender(this);
			
			if(!_dragging)
				return;
			
			_startDraggle.x = NaN;
			_startDraggle.y = NaN;
			_lastDraggle.x = NaN;
			_lastDraggle.y = NaN;
			
			draggle.stopDrag();
			Mouse.cursor = MouseCursor.AUTO;
			
			_dragging = false;
			_currentDragBehavior === this && (_currentDragBehavior = null);
			
			_dragPrepareTime = 0;
			
			smartDispatchEvent(DragEvent.DRAG_END);
			
			// finally change state:
			tb_drag::state = DragState.STATIC;
			
		}
		
		
		public function cancel(returnToStartPosition:Boolean = true):void
		{
			// anyway:
			removePretender(this);

			tb_drag::state = DragState.CANCELING;
			
			returnToStartPosition && this.returnToStartPosition();
			
			smartDispatchEvent(DragEvent.DRAG_CANCEL);
			
			// stop:
			upHandler();
		}
		
		protected function returnToStartPosition():void
		{
			if(!_dragging)
				return;
			
			const startDraggle:Point = startDraggle;
			
			// move:
			draggle.x = startDraggle.x,
			draggle.y = startDraggle.y;
			
			//TODO: wait transition ending
		}
		
		protected function calculateDragBounds():Rectangle
		{
			var result:Rectangle;
			
			if(virtualBounds)
				return virtualBounds;
			else{
				if(!bounds)
					return null;
			
				result = bounds.getBoundsRelativeChild(draggle);
			}
			
			if(!result)
				return null;
					
			result.width -= draggle.width * draggle.scaleX;
			result.height -= draggle.height * draggle.scaleY;
			
			if(result)
				switch(direction)
				{
					case(DragDirection.LEFT):
					{
						//TODO
						break;
					}
						
					case(DragDirection.RIGHT):
					{
						result.width += result.x - _target.x;
						result.x = _target.x;
						break;
					}
						
					case(DragDirection.UP):
					{
						//TODO
						break;
					}
						
					case(DragDirection.DOWN):
					{
						result.height += result.y - _target.y;
						result.y = _target.y;
						break;
					}
						
					case(DragDirection.HORIZONTAL):
					{
						result.y = _target.y;
						result.height = 0;
						break;
					}
						
					case(DragDirection.VERTICAL):
					{
						result.x = _target.x;
						result.width = 0;
						break;
					}
						
				}
			
			return result;
		}
		
		protected function recogniseDirection(a:Point, b:Point):uint
		{
			if(int(b.x) == int(a.x) && int(b.y) == int(a.y))
				return DragDirection.NO_DIRECTION;
			
			const angle:Number = angleAB(a, b);
			
			return DragDirection.getValueByAngle(angle);
		}
		
		//TODO: optimize me!
		protected function recogniseDraggleDirection():void
		{
			const draggle:Point = new Point(draggle.x, draggle.y);
			
			if(int(draggle.x) == int(_lastDraggle.x) && int(draggle.y) == int(_lastDraggle.y))
			{
				_currentDraggleDirection = DragDirection.NO_DIRECTION;
				return;
			}
			
			const angle:Number = angleAB(_lastDraggle, draggle);
			
			_currentDraggleDirection = DragDirection.getValueByAngle(angle);
			
			// finally:
			_lastDraggle.x = draggle.x;
			_lastDraggle.y = draggle.y;
			
			needRecogniseDraggleDirection = false;
		}
		
		protected function recogniseMouseDirection():void
		{
			_currentMouseDirection = recogniseDirection(_lastMouse, new Point(mouseCoordinateSpaceCurrent.mouseX, mouseCoordinateSpaceCurrent.mouseY));
			
			// finally:
			_lastMouse.x = mouseCoordinateSpaceCurrent.mouseX;
			_lastMouse.y = mouseCoordinateSpaceCurrent.mouseY;
			
			needRecogniseMouseDirection = false;
		}
		
		private function setupMouseCoordinateSpaceCurrent(eventTarget:Object = null):void
		{
			_mouseCoordinateSpaceCurrent = mouseCoordinateSpace || draggle || eventTarget as DisplayObject || stage;
		}

        //------- handlers / callbacks -------//

        protected function downHandler(e:MouseEvent):void
        {
            if(e.target is INotDraggle || (considerParent && hasParent(e.target as DisplayObject, INotDraggle)))
                return;


            setupMouseCoordinateSpaceCurrent(e.currentTarget as DisplayObject);
            if(mouseCoordinateSpaceCurrent)
                _startMouse.x = _lastMouse.x = mouseCoordinateSpaceCurrent.mouseX,
                        _startMouse.y = _lastMouse.y = mouseCoordinateSpaceCurrent.mouseY;

            mouseRecogniseCount = 0;

            initializeTempListeners();

            !_useCapture && e.stopImmediatePropagation();

            addPretender(this);
        }

        protected function moveHandler(e:MouseEvent):void
        {
            if(mouseRecogniseCount++ >= mouseRecogniseEvery)
                _lastMouse.x = mouseCoordinateSpaceCurrent.mouseX,
                        _lastMouse.y = mouseCoordinateSpaceCurrent.mouseY,
                        mouseRecogniseCount = 0;

            needRecogniseDraggleDirection = true;
            needRecogniseMouseDirection = true;

            _dragPrepareTime = _dragPrepareTime || getTimer();

            if(!_dragging)
            {
                if(_dragPrepareTime !== _prepareDispatchTime)
                    tb_drag::state = DragState.PREPARING,
                            _prepareDispatchTime = _dragPrepareTime,
                            smartDispatchEvent(DragEvent.DRAG_PREPARE);
            }
            else
                return;


            // test drag-start offset (distance):
            if(startShiftDistance > Point.distance(_startMouse, _lastMouse))
                return;


            if(_currentDragBehavior && _currentDragBehavior !== this)
                return cancel(false);

            // recognise start-direction:
            if(!_dragging)
            {
                const startDirection:uint = recogniseDirection(_startMouse, _lastMouse);
                const isStartValid:Boolean = DragDirection.collisionAB(this.startDirection, startDirection);

                if(!isStartValid)
                    return cancel(false);
                else
                    cancelParentalPretenders(this);
            }

            startDrag();
        }

        protected function upHandler(e:Event = null):void
        {

            stopDrag();

            disposeTempListeners();

        }


        protected function leaveHandler(e:Event):void{
            cancel(false);
        }
		
		//----- utils
		
		protected function initializeTempListeners():void
		{
			stage.addEventListener(MouseEvent.MOUSE_MOVE, moveHandler, true, EventPriority.CURSOR_MANAGEMENT);
			stage.addEventListener(Event.MOUSE_LEAVE, leaveHandler);
            stage.addEventListener(Event.DEACTIVATE, leaveHandler);
		}
		
		protected function disposeTempListeners():void
		{
			stage && stage.removeEventListener(MouseEvent.MOUSE_MOVE, moveHandler, true);
			stage && stage.removeEventListener(Event.MOUSE_LEAVE, leaveHandler);
            stage && stage.removeEventListener(Event.DEACTIVATE, leaveHandler);
		}
		

		protected function smartDispatchEvent(type:String):void
		{
			hasEventListener(type) && dispatchEvent(new DragEvent(lastDispatchedEventType = type, _startMouse, _lastMouse, _startDraggle, _lastDraggle, currentDraggleDirection, lastDispatchedEventType === DragEvent.DRAG_CANCEL, dispatchToTarget));
		}
		
		//------------ get / set -------------//
		
		public function get useCapture():Boolean
		{
			return _useCapture;
		}
		
		public function set useCapture(value:Boolean):void
		{
			if(disposed || _useCapture === value)
				return;
			
			removeListeners();
			_useCapture = value;
			addListeners();
		}
		
		public function get state():String
		{
			return _state;
		}
		
		tb_drag function set state(value:String):void
		{
			if(_state === value)
				return;
			_state = value;
		}
		
		public static function get currentDragBehavior():DragBehavior
		{
			return _currentDragBehavior;
		}
		
		/**
		 * @copy InteractiveBehavior.target 
		 */		
		public function get draggle():Sprite
		{
			return _target as Sprite;
		}
		
		public function set draggle(value:Sprite):void
		{
			_target = value;
		}
		
		public function get dragging():Boolean
		{
			return _dragging;
		}
		
		tb_drag function setDragging(value:Boolean):void
		{
			_dragging = value;
		}
		
		public static function get dragging():Boolean
		{
			return currentDragBehavior && currentDragBehavior._dragging;
		}
		
		public function get dragStartTime():int
		{
			return _dragPrepareTime;
		}
		
		/**
		 * Direction of current drag relative to the <code>currentDraggle</code>.
		 */
		public function get currentDraggleDirection():uint
		{
			needRecogniseDraggleDirection && recogniseDraggleDirection();
			return _currentDraggleDirection;
		}
		
		/**
		 * Direction of current drag relative to the mouse or finger.
		 */
		public function get currentMouseDirection():uint
		{
			needRecogniseMouseDirection && recogniseMouseDirection();
			return _currentMouseDirection;
		}
		
		protected function get mouseCoordinateSpaceCurrent():DisplayObject
		{
			return _mouseCoordinateSpaceCurrent || setupMouseCoordinateSpaceCurrent(), _mouseCoordinateSpaceCurrent;
		}
		
		/**
		 * local mouse XY coordinates
		 */
		public function get lastMouse():Point
		{
			return _lastMouse;
		}
		
		/**
		 * local mouse XY coordinates
		 */
		public function get startMouse():Point
		{
			return _startMouse;
		}
		
		/**
		 * local target object XY coordinates
		 */
		public function get startDraggle():Point
		{
			return _startDraggle;
		}
		
		/**
		 * local target object XY coordinates
		 */
		public function get lastDraggle():Point
		{
			return _lastDraggle;
		}
		

		
		

		public function get active():Boolean
		{
			return _active;
		}

		public function set active(value:Boolean):void
		{
			if(_active === value)
				return;
			
			
			_active = value;

			if(value)
				addListeners();
			else{
				removeListeners();
				upHandler();
			}
			
		}



	}
}