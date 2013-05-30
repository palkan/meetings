package ru.teachbase.module.board.style
{
import flash.display.Graphics;

/**
	 * implementation of GraphicsStroke class.
	 * @author Aleksandr Kozlovskij (created: Apr 11, 2012)
	 */
	public final class FillStyle extends Object implements IGraphicsStyle
	{
		private static const defaults:FillStyle = new FillStyle();
		private static const properties:Array = ['color'];
		
		private var _changed:Boolean;
		
		/** Color of fill. */		
		public var color:uint = 0x0;
		private var _scale:Number = 1;
		
		/** @copy flash.display.DisplayObject.alpha */		
		public var alpha:Number = 1.0;
		
		//------------ constructor ------------//
		
		public function FillStyle(source:IGraphicsStyle = null)
		{
			_changed = true;
			source && extend(source);
		}
		
		//------------ initialize ------------//
		
		//--------------- ctrl ---------------//
		
		public function apply(graphics:Graphics):void
		{
			graphics.beginFill(color, alpha);
		}
		
		public function extend(source:IGraphicsStyle):void
		{
			if(source is FillStyle)
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
			return new FillStyle(this);
		}
		
		//------------ get / set -------------//
		
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