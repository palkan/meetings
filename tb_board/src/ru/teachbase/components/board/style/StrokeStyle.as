package ru.teachbase.components.board.style
{
import flash.display.Graphics;
import flash.display.LineScaleMode;

/**
	 * implementation of GraphicsStroke class.
	 * @author Aleksandr Kozlovskij (created: Apr 11, 2012)
	 */
	public final class StrokeStyle extends Object implements IGraphicsStyle
	{
		private static const defaults:StrokeStyle = new StrokeStyle();
		private static const properties:Array = ['caps', 'joints', 'scaleMode', 'miterLimit', 'pixelHinting', 'color', 'alpha', 'thickness'];
		
		private var _changed:Boolean;
		
		private var _caps:String = null;
		private var _joints:String = null;
		private var _scaleMode:String = LineScaleMode.NONE;
		
		/** @copy flash.display.GraphicsStroke.miterLimit */		
		public var miterLimit:Number = 3;
		/** @copy flash.display.GraphicsStroke.pixelHinting */		
		public var pixelHinting:Boolean = false;
		
		/** Color of line. */		
		public var color:uint = 0x0;
		/** @copy flash.display.DisplayObject.alpha */		
		public var alpha:Number = 1.0;
		
		private var _thickness:Number = NaN;
		private var _scale:Number = 1;
		
		//------------ constructor ------------//
		
		public function StrokeStyle(source:IGraphicsStyle = null)
		{
			_changed = true;
			source && extend(source);
		}
		
		//------------ initialize ------------//
		
		//--------------- ctrl ---------------//
		
		public function apply(graphics:Graphics):void
		{
			graphics.lineStyle(thicknessScaled, color, alpha, pixelHinting, _scaleMode, _caps, _joints, miterLimit);
		}
		
		public function extend(source:IGraphicsStyle):void
		{
			if(source is StrokeStyle)
				for(var i:int; i < properties.length; ++i)
					this[properties[i]] = source[properties[i]];
			else
				for(var key:String in source)
					if(properties.indexOf(key) != -1 || this.hasOwnProperty(key))
						this[key] = source[key];
		}
		
		public function reset(source:IGraphicsStyle = null):void
		{
			clear();
			source && extend(source);
		}
		
		public function clear():void
		{
			extend(defaults);
		}
		
		public function clone():IGraphicsStyle
		{
			return new StrokeStyle(this);
		}
		
		//------------ get / set -------------//
		
		/** @copy flash.display.GraphicsStroke.caps */		
		public function get caps():String
		{
			return _caps;
		}
		
		public function set caps(value:String):void
		{
			_caps = value;
			_changed = true;
		}
		
		/** @copy flash.display.GraphicsStroke.joints */		
		public function get joints():String
		{
			return _joints;
		}
		
		public function set joints(value:String):void
		{
			_joints = value;
			_changed = true;
		}
		
		/** @copy flash.display.GraphicsStroke.scaleMode */		
		public function get scaleMode():String
		{
			return _scaleMode;
		}
		
		public function set scaleMode(value:String):void
		{
			// not implemented yet
			//_scaleMode = value;
		}
		
		/** @copy flash.display.GraphicsStroke.thickness */
		public function get thickness():Number
		{
			return _thickness;
		}
		
		/**
		 * @private
		 */
		public function set thickness(value:Number):void
		{
			if(_thickness === value)
				return;
			
			_thickness = value;
		}
		
		/** @copy flash.display.GraphicsStroke.thickness */
		public function get thicknessScaled():Number
		{
			return thickness * _scale;
		}
		
		public function get scale():Number
		{
			return _scale;
		}
		
		public function set scale(value:Number):void
		{
			_scale = value;
		}
		
		public function get changed():Boolean
		{
			return _changed;
		}
	}
}