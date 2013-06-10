package ru.teachbase.behaviours.interfaces
{
import flash.geom.Point;
import flash.geom.Rectangle;

import mx.core.IVisualElement;

/**
	 * Implementation of this interface must be a container or cell who allows (or not) to drop other objects into self.
	 * @author Teachbase (created: Jan 25, 2012)
	 */
	public interface IDropCoordinateSpace extends IVisualElement
	{
		//------------ initialize ------------//
		
		//--------------- ctrl ---------------//
		
		function isPossibleDropFor(object:IDraggle):Boolean;
		
		
		function prepareDrop(object:IDraggleSnapshot, mouse:Point):void;
		function drop(object:IDraggleSnapshot, mouse:Point):void;
		function cancelDrop(object:IDraggleSnapshot):void;
		
		/**
		 * 
		 * @param point :Point in <b>local</b> coordinate space. 
		 * @return available drop-zone who contains <code>point</code>.
		 * <br/>
		 * <b>Note:</b> always returning <b>local</b> coords.
		 * @see #getDropBoundsForRect()
		 * 
		 */		
		//function getDropBoundsForPoint(local:Point):Rectangle;
		
		/**
		 * 
		 * @param rect :Rectangle in <b>local</b> coordinate space.
		 * @return available drop-zone who contains <code>rect</code>.
		 * <br/>
		 * <b>Note:</b> always returning <b>local</b> coords.
		 * @see #getDropBoundsForPoint()
		 * 
		 */		
		//function getDropBoundsForRect(local:Rectangle):Rectangle;
		
		/**
		 * 
		 * @param rect - drop-bounds form <code>getDropBoundsForPoint</code> and <code>getDropBoundsForRect</code>
		 * @return alignment (or side, or direction)
		 * </br><b>Posible values:</b>
		 * </br><code>DragDirection.<b>LEFT</b></code>
		 * </br><code>DragDirection.<b>RIGHT</b></code>
		 * </br><code>DragDirection.<b>UP</b></code>
		 * </br><code>DragDirection.<b>DOWN</b></code>
		 * </br><code>DragDirection.<b>ORTHOGONAL</b></code> using as <b>CENTER</b>
		 * </br><code>DragDirection.<b>NO_DIRECTION</b></code> using as <b>NONE</b>.
		 * 
		 * @see #getDropBoundsForPoint()
		 * @see #getDropBoundsForRect()
		 * @see ru.teachbase.behaviors.DragDirection
		 */		
		function getDropBoundsSide(localDropBounds:Rectangle):uint;
		
		/**
		 * 
		 * @return possible child's index for the <code>side</code>.
		 * 
		 * @see #getDropBoundsSide()
		 */		
		function getDropIndexBySide(side:uint):int;
		
		//------------ get / set -------------//
		
		//function get isEmpty():Boolean;
		
		//function get grid9():Rectangle;
		//function set grid9(centerCell:Rectangle):void;
		
		//------- handlers / callbacks -------//
	}
}