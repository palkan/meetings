package ru.teachbase.components.board.model
{
import flash.display.Graphics;

import ru.teachbase.components.board.style.FillStyle;
import ru.teachbase.components.board.style.StrokeStyle;

/**
	 * @author Aleksandr Kozlovskij (created: Mar 20, 2012)
	 */
	public interface IFigure
	{
		//------------ initialize ------------//

        function get instrument():String;
		
		//--------------- ctrl ---------------//
		
		function pointsUpdated(firstPointIndex:int = 0, length:int = int.MAX_VALUE):void
		
		function draw(firstPointIndex:int = 0, num:int = int.MAX_VALUE):void;
		
		function showPoints():void;
		function hidePoints():void;
		
		function addPoint(point:FigurePoint):void;
		function addPointAt(point:FigurePoint, index:uint):void;
		
		/**
		 * Overrides old point with new.
		 */		
		function setPoint(point:FigurePoint, index:uint):void;
		
		function getPointIndex(point:FigurePoint):int;
		function getPoint(index:uint):FigurePoint;
		function hasPoint(point:FigurePoint):Boolean;
		
		function removePoint(point:FigurePoint):FigurePoint;
		function removePointAt(index:uint):FigurePoint;
		
		//------ Transform / Scaling API ------//
		
		/**
		 * Changer self position and size relative to proportion: ((unscaled size of canvas) / (actual size of canvas))
		 */		
		function scaleRelativeCanvasWidth(value:Number):void;

        function moved(deltax:Number, deltay:Number):void;
		
		/**
		 * 
		 * @param value should be the desired width of the ru.teachbase.components.board. (using as scaling-factor).
		 * @return type: <code>Object</code> or <code>Array</code>
		 * <br/>
		 * <b>Format:</b>
		 * <br/>Object: <code>{1:{x:0, y:0}, 4:{x:0, y:0}}</code> - using if need tranfer changes only;
		 * <br/>Array: <code>[{x:0, y:0}, {x:0, y:0},]</code> - using if need tranfer all points.
		 * 
		 */		
		function getPointsRelativeCanvasWidth(value:Number):Object;
		
		//------------ get / set -------------//
		function get id():String;
		function get name():String;
		
		function get numPoints():uint;
		function set numPoints(value:uint):void;
		
		function get points():Vector.<FigurePoint>;
		
		function get complete():Boolean;
		function set complete(value:Boolean):void;
		
		function get mouseX():Number;
		function get mouseY():Number;
		
		function get graphics():Graphics;
		
		//----- net -----//
		function get external():ExternalFigure;
		function set external(value:ExternalFigure):void;
		
		//------ Transform / Scaling API ------//
		
		/**
		 * return unscaled size of canvas
		 * @return unscaled size of canvas
		 */		
		function get initialCanvasWidth():Number;
		
		function get scaleDelta():Number;
		
		
		
		function set scaleX(value:Number):void;
		function get scaleX():Number;
		
		function set scaleY(value:Number):void;
		function get scaleY():Number;
		
		function set width(value:Number):void;
		function get width():Number;
		
		function set height(value:Number):void;
		function get height():Number;
		
		function set rotation(value:Number):void;
		function get rotation():Number;
		
		//------ Styling API ------//
		
		function get stroke():StrokeStyle;
		function set stroke(value:StrokeStyle):void;
		
		function get fill():FillStyle;
		function set fill(value:FillStyle):void;
		
		//------- handlers / callbacks -------//
	}
}