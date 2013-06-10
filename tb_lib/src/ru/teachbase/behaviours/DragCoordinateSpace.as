package ru.teachbase.behaviours
{
import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.geom.Point;
import flash.geom.Rectangle;

import mx.core.ILayoutElement;

import ru.teachbase.behaviours.interfaces.IDragCoordinateSpace;

/**
	 * Base implementation of IDropCoordinateSpace
	 * @author Teachbase (created: Feb 7, 2012)
	 */
	public class DragCoordinateSpace implements IDragCoordinateSpace
	{
		private const bounds:Rectangle = new Rectangle();
		
		private var _disposed:Boolean;
		
		//---- catched:
		private var catch_element:DisplayObject;
		private var catch_container:DisplayObjectContainer;
		private var catch_getElementBounds:Rectangle;
		private var catch_getBoundsRelativeElement:Rectangle;
		private var catch_getElementLocalCoordinates:Point;
		
		//------------ constructor ------------//
		
		public function DragCoordinateSpace(container:DisplayObjectContainer = null, width:Number = 0, height:Number = 0)
		{
			container && setup(container, width, height);
		}
		
		//------------ initialize ------------//
		
		public function setup(container:DisplayObjectContainer, customWidth:Number = 0, customHeight:Number = 0):void
		{
			catch_container = container;
			
			bounds.setTo(x, y, customWidth || width, customHeight || height)
		}
		
		public function dispose():void
		{
			catch_element = catch_container = null;
			_disposed = true;
		}
		
		public function get disposed():Boolean
		{
			return _disposed;
		}
		
		//--------------- ctrl ---------------//
		
		public function getBoundsRelativeChild(child:DisplayObject):Rectangle
		{
			if(!catch_container || !catch_container.contains(child))
				return null;
			
			const bounds:Rectangle = catch_container.getRect(child);
			
			// apply custom:
			if(this.bounds.width > bounds.width || this.bounds.height > bounds.height)
				bounds.width = this.bounds.width,
				bounds.height = this.bounds.height;
			
			// Fix for Spark components in-layout coordinates:
			const element:ILayoutElement = child as ILayoutElement;
			const layoutBounds:Point = new Point(0, 0);
			if(element && (!child.x || (layoutBounds.x = element.getLayoutBoundsX())))
			{
				bounds.x += layoutBounds.x;
				bounds.y += layoutBounds.y;
			}
			
			return bounds;
		}
		
				
		public function contains(x:Number, y:Number):Boolean
		{
			return bounds.contains(x, y);
		}
		
		public function containsPoint(point:Point):Boolean
		{
			return bounds.containsPoint(point);
		}
		
		public function containsRect(rect:Rectangle):Boolean
		{
			return bounds.containsRect(rect);
		}
		
		
		//------------ get / set -------------//
		
		public function get x():Number
		{
			return bounds.x;
		}
		
		public function get y():Number
		{
			return bounds.y;
		}
		
		public function get width():Number
		{
			return bounds.width;
		}
		
		public function get height():Number
		{
			return bounds.height;
		}
		
	}
}