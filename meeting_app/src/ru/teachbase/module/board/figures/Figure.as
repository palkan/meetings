package ru.teachbase.module.board.figures
{
import flash.display.IBitmapDrawable;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.geom.Point;

import ru.teachbase.module.board._figures;
import ru.teachbase.module.board.components.BoardTextInput;
import ru.teachbase.module.board.style.FillStyle;
import ru.teachbase.module.board.style.StrokeStyle;

/**
	 * @author Aleksandr Kozlovskij (created: Mar 21, 2012)
	 */
	public class Figure extends Sprite implements IFigure, IBitmapDrawable
	{
		private const _points:Vector.<FigurePoint> = new Vector.<FigurePoint>();
		private const _visualPoints:Vector.<FigureVisualPoint> = new Vector.<FigureVisualPoint>();
		
		private const pointsContainer:Sprite = new Sprite();
		
		private var _draw:Function;
		public var instrument:String;
		private var _complete:Boolean;
		
		/**
		 * Position relative to unscaled size of canvas
		 */		
		private var _initial:Point;
		protected var _initialCanvasWidth:Number = 1;
		
		private var _external:ExternalFigure;
		public var textField:BoardTextInput;
		
		private var _scaleDelta:Number = 1;
		
		public var page_id:int = 0;
		
		// styles:
		private var _stroke:StrokeStyle = new StrokeStyle();
		private var _fill:FillStyle;
		
		
		//styles params
		private var _color:uint = 0;
		private var _thickness:int = 1;
		private var _fillColor:uint = 0;
		
		
		
		
		//------------ constructor ------------//

		
		/**
		 * @param draw:Function must be link to function:<br/>
		 * <code>
		 * function draw(firstPointIndex:int = 0, num:int = int.MAX_VALUE, figure:IFigure = null):void
		 * </code>
		 */		
		public function Figure(draw:Function, instrumentType:String, initialCanvasWidth:Number, initialPosition:Point = null)
		{
			super();
			_draw = draw;
			instrument = instrumentType;
			
			_initial = initialPosition || new Point();
			_initialCanvasWidth = initialCanvasWidth;
			
			pointsContainer.mouseEnabled = false;
			
			buttonMode = useHandCursor = doubleClickEnabled = false;
			
			
			
		}
		//------------ initialize ------------//
		
		//--------------- ctrl ---------------//
		
		public function notifyExternal(param:String, value:*):void
		{
			if(_external)
				_external.sendUpdate(param, value, instrument);
			
		}
		
		
		public function draw(firstPointIndex:int = 0, num:int = int.MAX_VALUE):void
		{
			num = Math.min(num, (_points.length - 1) - firstPointIndex);
			
			//TODO: create new points by filtered _points
			
			_draw && _draw(_points, this);
		}
		
		public function pointsUpdated(firstPointIndex:int = 0, num:int = int.MAX_VALUE):void
		{
			draw(firstPointIndex, num);
			
			//notifyExternal('points', _points);
		}
		
		internal function visualPointUpdated(index:int):void
		{
			_points[index].x = _visualPoints[index].x;
			_points[index].y = _visualPoints[index].y;
			draw(index, 1);
			
			//notifyExternal('points', _points);
		}
		
		public function showPoints():void
		{
			if(pointsContainer.numChildren !== points.length)
				validateVisualPoints();
			addChild(pointsContainer);
		}
		
		public function hidePoints():void
		{
			contains(pointsContainer) && removeChild(pointsContainer);
		}
		
		
		
		private function validateVisualPoints():void
		{
			var need:int = _points.length - _visualPoints.length;
			
			// sync length:
			_visualPoints.length = Math.max(_visualPoints.length, _points.length);
			
			// add:
			if(need > 0)
			{
				for(var i:int; i < _points.length; ++i)
				{
					var p:FigurePoint = _points[i];
					var v:FigureVisualPoint = _visualPoints[i] || (_visualPoints[i] = new FigureVisualPoint(i, this));
					v.x = p.x;
					v.y = p.y;
					!v.parent && pointsContainer.addChild(v);
				}
			}
		}
		
		public function addPoint(point:FigurePoint):void
		{
			_points.push(point);
			
			//notifyExternal('points', _points);
		}
		
		public function addPointAt(point:FigurePoint, index:uint):void
		{
			_points.splice(Math.min(index, _points.length), 0, point);
			
			//notifyExternal('points', _points);
		}
		
		public function setPoint(point:FigurePoint, index:uint):void
		{
			_points.length = Math.max(_points.length, index + 1);
			_points[index] = point;
			
			//notifyExternal('points', _points);
		}
		
		public function getPoint(index:uint):FigurePoint
		{
			return _points[index];
		}
		
		public function getPointIndex(point:FigurePoint):int
		{
			return _points.indexOf(point);
		}
		
		public function hasPoint(point:FigurePoint):Boolean
		{
			return _points.indexOf(point) !== -1;
		}
		
		public function removePoint(point:FigurePoint):FigurePoint
		{
			const result:FigurePoint = _points.splice(_points.indexOf(point), 1)[0];
		//	notifyExternal('points', _points);
			return result;
		}
		
		public function removePointAt(index:uint):FigurePoint
		{
			const result:FigurePoint = _points.splice(index, 1)[0];
		//	notifyExternal('points', _points);
			return result;
		}
		
		
		//------------ Scaling IMPL -------------//
		
		public function scaleRelativeCanvasWidth(value:Number):void
		{
			_scaleDelta = value / _initialCanvasWidth;
			scaleX = scaleY = _scaleDelta;
			super.x = _initial.x * _scaleDelta;
			super.y = _initial.y * _scaleDelta;
			
			if(_stroke)
				_stroke.scale = _scaleDelta;
		}
		
		public function getPointsRelativeCanvasWidth(value:Number):Object
		{
			return [{x:0, y:0}, {x:0, y:0}];
		}
		
		public function get initialCanvasWidth():Number
		{
			return _initialCanvasWidth;
		}
		
		_figures function setInitialCanvasWidth(value:Number):void
		{
			_initialCanvasWidth = value;
		}
		
		public function get scaleDelta():Number
		{
			return _scaleDelta;
		}
		
		//------------ get / set -------------//
		
		override public function set x(value:Number):void
		{
			super.x = _initial.x = value;
		}
		
		override public function set y(value:Number):void
		{
			super.y = _initial.y = value;
		}
		
		
		
		public function get id():String
		{
			return _external ? _external.id : null;
		}
		
		public function get external():ExternalFigure
		{
			return _external;
		}
		
		/**
		 * @private
		 */		
		public function set external(value:ExternalFigure):void
		{
			if(_external === value)
				return;
			
			_external = value;
		}
		
		public function get numPoints():uint
		{
			return _points.length;
		}
		
		/**
		 * @private
		 */		
		public function set numPoints(value:uint):void
		{
			const old:uint = _points.length;
			_points.length = value;
			
		//	if(value !== old)
				//notifyExternal('points', _points);
		}
		
		public final function get points():Vector.<FigurePoint>
		{
			return _points;
		}
		
		public function get complete():Boolean
		{
			return _complete;
		}
		
		public function set complete(value:Boolean):void
		{
			if(_complete === value)
				return;
			
			/*if((_complete = value))
				addEventListener(MouseEvent.MOUSE_OVER, overHandler),
					addEventListener(MouseEvent.MOUSE_OUT, outHandler),
					showPoints();
			else
				removeEventListener(MouseEvent.MOUSE_OVER, overHandler),
					removeEventListener(MouseEvent.MOUSE_OUT, outHandler),
					hidePoints();*/
			
		//	notifyExternal('complete', _complete);
			notifyExternal('points', _points);
		}
		
		//-- styles --//
		
		public function get stroke():StrokeStyle
		{
			return _stroke;
		}
		
		public function set stroke(value:StrokeStyle):void
		{
			if(_stroke === value)
				return;
			
			_stroke = value;
		}
		
		public function get fill():FillStyle
		{
			return _fill;
		}
		
		public function set fill(value:FillStyle):void
		{
			if(_fill === value)
				return;
			
			_fill = value;
		}
		
		//------- handlers / callbacks -------//
		
		private function overHandler(e:MouseEvent):void
		{
		//	complete && showPoints();
		}
		
		private function outHandler(e:MouseEvent):void
		{
			//hidePoints();
		}
		
		
		public function set color(value:uint):void
		{
			_color = value;
			_stroke.color = value;
		}

		public function get color():uint
		{
			return _color;
		}

		public function get thickness():int
		{
			return _thickness;
		}

		public function set thickness(value:int):void
		{
			_thickness = value;
			
			_stroke.thickness = value;
			
		}

		public function get fillColor():uint
		{
			return _fillColor;
		}

		public function set fillColor(value:uint):void
		{
			_fillColor = value;
			
			_fill = new FillStyle();
			_fill.color = value;
			
		}



	}
}