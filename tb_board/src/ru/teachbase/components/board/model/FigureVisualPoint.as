package ru.teachbase.components.board.model
{
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.display.Stage;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Matrix;

/**
	 * @author Aleksandr Kozlovskij (created: Mar 21, 2012)
	 */
	public final class FigureVisualPoint extends Sprite
	{
		private static var bitmapData:BitmapData;
		
		private var _index:int;
		private var _parent:Figure;
		
		//------------ constructor ------------//
		
		public function FigureVisualPoint(index:int, parent:Figure)
		{
			super();
			_index = index;
			_parent = parent;
			
			alpha = .01;
		//	buttonMode = true;
			//useHandCursor = true;
			mouseEnabled = false;
			
			const scale:Number = .6;
			const width:Number = bitmapData.width * scale;
			const height:Number = bitmapData.height * scale;
			
			const m:Matrix = new Matrix();
			m.translate(-(bitmapData.width >> 1), -(bitmapData.height >> 1));
			m.scale(scale, scale);
			
			graphics.beginBitmapFill(bitmapData, m, false, true);
			graphics.drawRect(-(width >> 1), -(height >> 1), width, height);
			graphics.endFill();
			
			/*const bitmap:Bitmap = new Bitmap(bitmapData, PixelSnapping.ALWAYS);
			bitmap.x = -(bitmap.width >> 1);
			bitmap.y = -(bitmap.height >> 1);
			addChild(bitmap);*/
			
			//addEventListener(MouseEvent.MOUSE_OVER, overHandler);
			//addEventListener(MouseEvent.MOUSE_OUT, outHandler);
		//	addEventListener(MouseEvent.MOUSE_DOWN, downHandler);
		}
		
		//------------ initialize ------------//
		
		//--------------- ctrl ---------------//
		
		//------------ get / set -------------//
		
		//------- handlers / callbacks -------//
		
		private function downHandler(e:MouseEvent):void
		{
			stage.addEventListener(MouseEvent.MOUSE_MOVE, moveHandler);
			stage.addEventListener(MouseEvent.MOUSE_UP, upHandler);
			stage.addEventListener(Event.MOUSE_LEAVE, upHandler);
			startDrag();
			
			/*e.preventDefault();
			e.stopImmediatePropagation();*/
		}
		
		private function moveHandler(e:MouseEvent):void
		{
			_parent.visualPointUpdated(_index);
		}
		
		private function upHandler(e:Event):void
		{
			stopDrag();
			
			// if currently removed from stage:
			const stage:Stage = this.stage || e.currentTarget as Stage;
			
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, moveHandler);
			stage.removeEventListener(MouseEvent.MOUSE_UP, upHandler);
			stage.removeEventListener(Event.MOUSE_LEAVE, upHandler);
		}
		
		
		//---
		
		private function overHandler(e:MouseEvent):void
		{
			alpha = 1;
		}
		
		private function outHandler(e:MouseEvent):void
		{
			alpha = .01;
		}
	}
}