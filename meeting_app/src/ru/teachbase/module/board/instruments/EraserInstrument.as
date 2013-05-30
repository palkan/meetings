package ru.teachbase.module.board.instruments
{
import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.filters.GlowFilter;
import flash.geom.Rectangle;

import ru.teachbase.module.board.figures.Figure;
import ru.teachbase.module.board.figures.FigureManager;
import ru.teachbase.utils.helpers.*;
import ru.teachbase.utils.shortcuts.style;

/**
	 * @author Vova Dem (created: Aug 15, 2012)
	 */
	public class EraserInstrument extends Instrument
	{
		// mode:
		public static const MOUSE:Namespace = new Namespace('mouseInteractionMode');
		public static const TOUCH:Namespace = new Namespace('touchInteractionMode');
		public static var MODE:Namespace = MOUSE;
		
		
		private const DELTA:int = 10;
		
		
		
		
		private const _b:GlowFilter = new GlowFilter(0xff1100,1,3,3,2,1,false,true);
		
		private const _filters:Array =[_b];
		
		private var icon:DisplayObject;
		
		private var frameContainer:Sprite;
		
		
		private var _lastFigure:Figure;
		
		private var _isDown:Boolean = false;
		
		//------------ constructor ------------//
		
		public function EraserInstrument()
		{
			super(InstrumentType.ERASER);
			
			icon = style("wb","deleteBucket");
			
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
				//frameContainer = new Sprite();
				//frameContainer.mouseEnabled = false;
				icon.visible = false;
				//(target as DisplayObjectContainer).addChild(frameContainer);
				(target as DisplayObjectContainer).addChild(icon);
				target.addEventListener(MouseEvent.MOUSE_OVER, detectFigureHandler);//,true,EventPriority.CURSOR_MANAGEMENT);
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
			//(target as DisplayObjectContainer).removeChild(frameContainer);
			(target as DisplayObjectContainer).removeChild(icon);
			target.removeEventListener(MouseEvent.MOUSE_OVER, detectFigureHandler);
			target.removeEventListener(MouseEvent.MOUSE_DOWN, updownHandler);
			stage.removeEventListener(MouseEvent.MOUSE_UP, updownHandler);
			super.dispose();
		}
		
		
		//--------------- handlers ------------//
		
		private function detectFigureHandler(event:MouseEvent):void
		{
			
			if(event.target is Figure){
				var _f:Figure = event.target as Figure;
				if(!_lastFigure){
					_f.filters = _filters;
					_lastFigure = _f;
						
					target.addEventListener(MouseEvent.CLICK, onDeleteFigure);
					
					if(_isDown)
						manager.removeFigure((event.target as Figure).id);
					
				}
				
			}else{
				
				if(_lastFigure)
					_lastFigure.filters = [];
				
				_lastFigure = null;
				
			//	hideIcon();
				
				//frameContainer.graphics.clear();
				
				target.removeEventListener(MouseEvent.CLICK, onDeleteFigure);
			}
			
			//event.stopImmediatePropagation();
		}
		
		private function onDeleteFigure(event:MouseEvent):void
		{
			
			if(event.target is Figure)
				manager.removeFigure((event.target as Figure).id);
			
		}
		
		//--------------- ctrl ---------------//
		
		
		private function drawFrame(item:Figure):void{
			
			var bounds:Rectangle = item.getBounds(item);
			frameContainer.graphics.lineStyle(1,0xFF1100,1);
			frameContainer.graphics.beginFill( 0xFF1100, 0.1 );
			frameContainer.graphics.drawRect(bounds.x, bounds.y, bounds.width, bounds.height);
			frameContainer.graphics.endFill();
			//frameContainer.x = item.x+(target as BoardCanvas).figureContainer.x;
			//frameContainer.y = item.y+(target as BoardCanvas).figureContainer.y;
		}
		
		
		
		
		
		private function showIcon():void{
			
			
			updateIconOnMove(null);
			
			target.addEventListener(MouseEvent.MOUSE_MOVE,updateIconOnMove);
			
			icon.visible = true;
		}
		
		
		
		private function hideIcon():void{
			
			
			target.removeEventListener(MouseEvent.MOUSE_MOVE,updateIconOnMove);
			
			icon.visible = false;
			
			
		}
		
		
		private function updateIconOnMove(event:MouseEvent):void
		{
			
		//	icon.x = (target as DisplayObject).mouseX+DELTA+(target as BoardCanvas).figureContainer.x;
		//	icon.y = (target as DisplayObject).mouseY-DELTA+(target as BoardCanvas).figureContainer.y;
			
		}		
		
		
				
		//------------ get / set -------------//
		
		public function get container():DisplayObjectContainer
		{
			return manager.container;
		}
		
		
	}
}