package ru.teachbase.module.board.instruments
{
import flash.display.DisplayObjectContainer;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Point;

import mx.core.EventPriority;

import ru.teachbase.core.App;
import ru.teachbase.module.board.events.BoardTextEvent;
import ru.teachbase.module.board.figures.Figure;
import ru.teachbase.module.board.figures.FigureManager;
import ru.teachbase.utils.helpers.mouseGrandChildren;

/**
	 * @author Aleksandr Kozlovskij (created: Apr 12, 2012)
	 */
	public class TextInstrument extends Instrument
	{
		
		public static const FIXED_WIDTH:int = 400;
		public static const SEND_TIMEOUT:int = 1000;
		
				
		protected const startGlobal:Point = new Point();
		private var figure:Figure;
		
		
		//------------ constructor ------------//
		
		public function TextInstrument()
		{
			super(InstrumentType.TEXT);
		}
		
		//------------ initialize ------------//
		
		internal static function initialize():void
		{
			registerClass(InstrumentType.TEXT, TextInstrument);
		}
		
		//--------------- ctrl ---------------//
		
		override public function initialize(manager:FigureManager):void
		{
			super.initialize(manager);
			
			if(super.manager) 
			{
				mouseGrandChildren(manager.container.page.textContainer  as DisplayObjectContainer, true);
				//target.addEventListener(MouseEvent.MOUSE_OVER, detectExistingText);
				manager.container.addEventListener(BoardTextEvent.UPDATE, updateHandler,true,EventPriority.CURSOR_MANAGEMENT);
				//,true,EventPriority.CURSOR_MANAGEMENT);
			}
			
			
			if(target)
				target.addEventListener(MouseEvent.CLICK,onClickHandler);
		}
		
		private function updateHandler(event:Event):void
		{
			if(event.target.parent is Figure){
				(event.target.parent as Figure).notifyExternal("text",event.target.text);
			}
		}
		
		override public function dispose():void
		{
			if(super.manager)
			{
				mouseGrandChildren(manager.container.page.textContainer as DisplayObjectContainer,false);
				//target.removeEventListener(MouseEvent.MOUSE_OVER, detectExistingText);
				manager.container.removeEventListener(BoardTextEvent.UPDATE, updateHandler,true);
				
				super.dispose();
			}
			
			if(target)
				target.removeEventListener(MouseEvent.CLICK,onClickHandler);
			
		}
		
		private function onClickHandler(event:MouseEvent):void
		{
			
			if(event.target != target)
				return;
			
			
			var _canvasWidth:Number = manager.container.formatBounds.width;
			var _k:Number = FIXED_WIDTH / _canvasWidth;
			startGlobal.x = mouseX * _k;
			startGlobal.y = mouseY * _k;
			
			
			figure = manager.createText(startGlobal) as Figure;
			
			
			figure.textField && App.focusManager.setFocus(figure.textField);
			
		}		
		
		
		//------------ get / set -------------//
		
		//------- handlers / callbacks -------//
		private function detectExistingText(event:MouseEvent):void
		{
			if(event.target is Figure && (event.target as Figure).instrument === InstrumentType.TEXT){
				
				
			}
			
		}
		
	}
}