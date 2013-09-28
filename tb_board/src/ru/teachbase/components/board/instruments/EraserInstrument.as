package ru.teachbase.components.board.instruments
{
import flash.display.DisplayObjectContainer;
import flash.events.MouseEvent;
import flash.filters.GlowFilter;

import mx.core.EventPriority;

import ru.teachbase.assets.wb.EraserCursor;

import ru.teachbase.components.board.FigureManager;
import ru.teachbase.components.board.model.Figure;

/**
	 * @author Vova Dem (created: Aug 15, 2012)
	 */
	public class EraserInstrument extends Instrument
	{

		private const _b:GlowFilter = new GlowFilter(0xff1100,1,3,3,2,1,false,true);
		
		private const _filters:Array =[_b];
		
		private var _lastFigure:Figure;
		
		private var _isDown:Boolean = false;
		
		//------------ constructor ------------//
		
		public function EraserInstrument()
		{
			super(InstrumentType.ERASER);

            _cursor = (new EraserCursor()).toDisplayObject();

		}
		
		//------------ initialize ------------//
		
		internal static function initialize():void
		{
			registerClass(InstrumentType.ERASER, EraserInstrument);
		}
		
		override public function initialize(manager:FigureManager):void
		{
			super.initialize(manager);
			
			if(super.manager && target)
			{
				target.addEventListener(MouseEvent.MOUSE_OVER, detectFigureHandler,true,EventPriority.CURSOR_MANAGEMENT);
				target.addEventListener(MouseEvent.MOUSE_DOWN, updownHandler);
				stage.addEventListener(MouseEvent.MOUSE_UP, updownHandler);
			}
		}
		
		private function updownHandler(event:MouseEvent):void
		{
			_isDown = (event.type === MouseEvent.MOUSE_DOWN);	
		}
		
		override public function dispose():void
		{
			target.removeEventListener(MouseEvent.MOUSE_OVER, detectFigureHandler,true);
			target.removeEventListener(MouseEvent.MOUSE_DOWN, updownHandler);
			stage.removeEventListener(MouseEvent.MOUSE_UP, updownHandler);
			super.dispose();
		}
		
		
		//--------------- handlers ------------//
		
		private function detectFigureHandler(e:MouseEvent):void
		{
			
			if(e.target is Figure){
				var _f:Figure = e.target as Figure;
				if(!_lastFigure){
					_f.filters = _filters;
					_lastFigure = _f;

                    _lastFigure.addEventListener(MouseEvent.MOUSE_OUT,figureOutHandler);
					target.addEventListener(MouseEvent.CLICK, onDeleteFigure);
					
					if(_isDown)
						manager.removeFigure((e.target as Figure).id);
					
				}

                e.stopImmediatePropagation();
				
			}
        }

        private function figureOutHandler(e:MouseEvent):void{

				if(_lastFigure)
					_lastFigure.filters = [];

                _lastFigure.removeEventListener(MouseEvent.MOUSE_OUT,figureOutHandler);

				_lastFigure = null;

				target.removeEventListener(MouseEvent.CLICK, onDeleteFigure);
		}


		
		private function onDeleteFigure(e:MouseEvent):void
		{
			
			if(e.target is Figure)
				manager.removeFigure((e.target as Figure).id);
			
		}
		
		//--------------- ctrl ---------------//
		

		//------------ get / set -------------//
		
		public function get container():DisplayObjectContainer
		{
			return manager.canvas;
		}
		
		
	}
}