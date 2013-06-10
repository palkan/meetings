package ru.teachbase.behaviours.interfaces
{

import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.geom.Rectangle;

import ru.teachbase.utils.interfaces.IDisposable;

/**
	 * @copy flash.geom.Rectangle
	 * @author Teachbase (created: Feb 6, 2012)
	 */
	public interface IDragCoordinateSpace extends IDisposable
	{
		//------------ initialize ------------//
		
		/**
		 * 
		 * Initialize or reinitialize by new container's bounds.
		 * 
		 * @param container :DisplayObjectContainer
		 * @param customWidth use it for flex/spark components for override original width
		 * @param customHeight overrides original height
		 * 
		 */		
		function setup(container:DisplayObjectContainer, customWidth:Number = 0, customHeight:Number = 0):void;
		
		//--------------- ctrl ---------------//
		
		/**
		 * 
		 * @param element
		 * @return 
		 * 
		 * @see #setup()
		 */		
		function getBoundsRelativeChild(child:DisplayObject):Rectangle;
		
			
		//------------ get / set -------------//
		
		function get x():Number;
		function get y():Number;
		function get width():Number;
		function get height():Number;
		
		//------- handlers / callbacks -------//
	}
}