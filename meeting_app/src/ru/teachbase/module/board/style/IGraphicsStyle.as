package ru.teachbase.module.board.style
{
import flash.display.Graphics;

/**
	 * Base & abstract class.
	 * @author Aleksandr Kozlovskij (created: Apr 11, 2012)
	 */
	public interface IGraphicsStyle
	{
		//------------ initialize ------------//
		
		/** Clean & Set new data from <code>source</code> if it passed to arguments. */
		function reset(source:IGraphicsStyle = null):void;
		
		/** Merge self data with data from <code>source</code> if valid. */
		function extend(source:IGraphicsStyle):void;
		
		/** Clean self data to defaults. */
		function clear():void;
		
		//--------------- ctrl ---------------//
		
		function apply(graphics:Graphics):void;
		
		
		function clone():IGraphicsStyle;
		
		//------------ get / set -------------//
		
		/** If U call <code>apply()</code> method, then <code>changing</code> will be setted to false. */
		function get changed():Boolean;
		
		function get scale():Number;
		function set scale(value:Number):void;
		
		//------- handlers / callbacks -------//
		
	}
}