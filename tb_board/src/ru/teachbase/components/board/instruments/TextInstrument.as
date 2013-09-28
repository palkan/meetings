package ru.teachbase.components.board.instruments
{
import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Point;

import mx.core.EventPriority;
import mx.core.FlexGlobals;
import mx.managers.FocusManager;
import mx.managers.IFocusManagerContainer;

import ru.teachbase.components.board.FigureManager;
import ru.teachbase.components.board.events.BoardTextEvent;
import ru.teachbase.components.board.model.Figure;
import ru.teachbase.utils.helpers.mouseGrandChildren;

/**
	 */
	public class TextInstrument extends Instrument
	{
		
		public static const FIXED_WIDTH:int = 400;
		public static const SEND_TIMEOUT:int = 1000;
		
				
		protected const startGlobal:Point = new Point();

		private var _figure:Figure;

        private var _focusManager:FocusManager;
		
		
		//------------ constructor ------------//
		
		public function TextInstrument()
		{
			super(InstrumentType.TEXT);

            _focusManager=new FocusManager(FlexGlobals.topLevelApplication as IFocusManagerContainer);

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
				mouseGrandChildren(manager.canvas.page.textContainer  as DisplayObjectContainer, true);
				manager.canvas.addEventListener(BoardTextEvent.UPDATE, updateHandler,true,EventPriority.CURSOR_MANAGEMENT);
			}
			
			
			if(target)
				target.addEventListener(MouseEvent.CLICK,onClickHandler);
		}
		
		private function updateHandler(event:Event):void
		{
			if(event.target.parent is Figure){
                const fig:Figure = event.target.parent as Figure;

                if(!fig.complete) manager.completeFigure(fig);

				fig.notifyExternal("data",{text:event.target.text});
			}
		}
		
		override public function dispose():void
		{
			if(super.manager)
			{
				mouseGrandChildren(manager.canvas.page.textContainer as DisplayObjectContainer,false);
				manager.canvas.removeEventListener(BoardTextEvent.UPDATE, updateHandler,true);
			}
			
			if(target)
				target.removeEventListener(MouseEvent.CLICK,onClickHandler);

            super.dispose();
		}
		
		private function onClickHandler(e:MouseEvent):void
		{
			if(isTextFigure(e.target as DisplayObject) || !(e.target is Figure || e.target == target))
				return;
			
			
			var _canvasWidth:Number = manager.canvas.formatBounds.width;
			var _k:Number = FIXED_WIDTH / _canvasWidth;
			startGlobal.x = mouseX * _k;
			startGlobal.y = mouseY * _k;
			
			
			_figure = manager.createText(startGlobal) as Figure;
			
			
			_figure.textField && _focusManager && _focusManager.setFocus(_figure.textField);
			
		}

        private function isTextFigure(obj:DisplayObject):Boolean{

           return (obj is Figure && (obj as Figure).instrument === InstrumentType.TEXT);

        }
		
		
		//------------ get / set -------------//
		
		//------- handlers / callbacks -------//


	}
}