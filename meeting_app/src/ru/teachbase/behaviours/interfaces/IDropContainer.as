package ru.teachbase.behaviours.interfaces
{

import flash.geom.Point;

/**
	 * @author Teachbase (created: Jan 27, 2012)
	 */
	public interface IDropContainer
	{
		//------------ initialize ------------//
		
		//--------------- ctrl ---------------//
		
		function hasDropUnderPoint(point:Point):Boolean;
		function getDropUnderPoint(point:Point):IDropCoordinateSpace;
		
		function addSnapshot(snapshot:IDraggleSnapshot, position:Point):void;
		function removeSnapshot(snapshot:IDraggleSnapshot):void;
		
		//------------ get / set -------------//
		
		//------- handlers / callbacks -------//
	}
}