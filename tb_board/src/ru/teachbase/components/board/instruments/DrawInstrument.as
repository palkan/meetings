package ru.teachbase.components.board.instruments
{
import flash.display.DisplayObjectContainer;
import flash.display.Graphics;
import flash.events.MouseEvent;
import flash.geom.Point;

import ru.teachbase.components.board.FigureManager;
import ru.teachbase.components.board.model.FigurePoint;
import ru.teachbase.components.board.model.IFigure;
import ru.teachbase.components.board.style.FillStyle;
import ru.teachbase.components.board.style.StrokeStyle;

/**
	 * @author Aleksandr Kozlovskij (created: Mar 23, 2012)
	 */
	public class DrawInstrument extends Instrument
	{
		protected const startGlobal:Point = new Point();
		protected var figure:IFigure;
		
		private var _hasEventDragListeners:Boolean;
		
		//------------ constructor ------------//
		
		public function DrawInstrument(tid:String)
		{
			super(tid);
		}
		
		//------------ initialize ------------//
		
		override final public function initialize(manager:FigureManager):void
		{
			super.initialize(manager);
			if(target)
				(target as DisplayObjectContainer).mouseChildren = false;
			addEventListeners();
		}
		
		protected function addEventListeners():void
		{
			if(target)
				target.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHanlder);
		}
		
		protected function removeEventListeners():void
		{
			if(target)
				target.removeEventListener(MouseEvent.MOUSE_DOWN, mouseDownHanlder);
		}
		
		protected function addEventDragListeners():void
		{
			if(target && stage)
				target.addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHanlder),
					stage.addEventListener(MouseEvent.MOUSE_UP, mouseUpHanlder),
					_hasEventDragListeners = true;
		}
		
		protected function removeEventDragListeners():void
		{
			if(target && stage)
				target.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHanlder),
					stage.removeEventListener(MouseEvent.MOUSE_UP, mouseUpHanlder),
					_hasEventDragListeners = false;
		}
		
		override public function dispose():void
		{
			removeEventListeners();
			_hasEventDragListeners && removeEventDragListeners();
			
			if(target)
				(target as DisplayObjectContainer).mouseChildren = true;
			
			super.dispose();
		}
		
		//--------------- ctrl ---------------//
		
		public function applyStyles(graphics:Graphics, stroke:StrokeStyle, fill:FillStyle = null):void
		{
			stroke.apply(graphics);
			fill && fill.apply(graphics);
		}
		
		protected function draw(points:Vector.<FigurePoint>, figure:IFigure = null):void
		{
			// template method
		}
		
		protected function completeFigure(figure:IFigure = null):void
		{
			manager.completeFigure(figure || this.figure);
		}
		
		public function doCompleteFigure(figure:IFigure = null):void
		{
			this.completeFigure(figure);
		}
		
		protected function isValidDown(e:MouseEvent):Boolean
		{
			return e.target === target;
		}
		
		//------------ get / set -------------//
		
		override public function getModifierFunction():Function
		{
			return this.draw;
		}
		
		//------- handlers / callbacks -------//
		
		protected function mouseDownHanlder(e:MouseEvent):void
		{
			if(!isValidDown(e))
				return;
			
			startGlobal.x = mouseX;
			startGlobal.y = mouseY;
			
			figure = manager.createFigure(startGlobal, draw, this);
			
			addEventDragListeners();
			
			active = true;
		}
		
		protected function mouseMoveHanlder(e:MouseEvent):void
		{
			// template method
		}
		
		protected function mouseUpHanlder(e:MouseEvent = null):void
		{
			removeEventDragListeners();
			
			completeFigure();
			
			active = false;
		}
	}
}