package ru.teachbase.components
{
import caurina.transitions.Tweener;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.events.Event;
import flash.geom.Rectangle;

import ru.teachbase.assets.images.PanelPlaceholder;
import ru.teachbase.behaviours.interfaces.IDraggle;
import ru.teachbase.behaviours.interfaces.IDraggleSnapshot;
import ru.teachbase.utils.extensions.ScaleBitmap;

/**
	 * @author Teachbase (created: Jan 27, 2012)
	 */
	public class DraggleSnapshot  extends Sprite implements IDraggleSnapshot
	{
		
		private static const panel:BitmapData = Bitmap(PanelPlaceholder.create()).bitmapData;
				
		private var _source:IDraggle;
		protected var sourceBitmap:Bitmap;
		
		protected const border:int = 4;
		private var _animate:Boolean;
		
		//------------ constructor ------------//
		
		public function DraggleSnapshot(source:IDraggle, animate:Boolean = true)
		{
			super();
			_source = source;
			_animate = animate;
			
			addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
			addEventListener(Event.REMOVED_FROM_STAGE, removedToStageHandler);
			
			mouseEnabled = mouseChildren = false;
		}
		
		//------------ initialize ------------//
		
		private function createSnapshot():void
		{
			try{
				sourceBitmap = createBitmap(source);
			}catch(e:Error){
				sourceBitmap = createBitmapBackOff(source);
			}
			
			const display:DisplayObject = source as DisplayObject;
			sourceBitmap.x = - display.mouseX;
			sourceBitmap.y = - display.mouseY;
			addChild(sourceBitmap);
			_animate && animate(sourceBitmap); 
		}
		
		protected function createBitmap(source:IDraggle):Bitmap
		{
			const bd:BitmapData = new BitmapData(source.width, source.height, true, 0x0);
			bd.draw(_source);
			
			var sourceBitmap:Bitmap = new ScaleBitmap(bd);
			sourceBitmap.scale9Grid = new Rectangle(border, border, source.width - border * 2, source.height - border * 2);
			return sourceBitmap;
		}
		
		
		protected function createBitmapBackOff(source:IDraggle):Bitmap
		{
			var _bmp:Bitmap = new Bitmap();
			_bmp.bitmapData = panel.clone();
			return _bmp;
		}
		
		protected function animate(sourceBitmap:Bitmap):void
		{
		    	Tweener.addTween(sourceBitmap, {x:mouseX, y:mouseY, time:.1, transition:"linear"});
		    	Tweener.addTween(sourceBitmap, {width:80, height:80, alpha:.6, time:.2, transition:"linear"});
		}
	
	
		public function move(x:Number,y:Number):void{
			this.x = x - this.width / 2;
			this.y = y - this.height / 2;
		}
	
		
		private function dispose():void
		{
			removeChildren();
			if(sourceBitmap)
				sourceBitmap.bitmapData.dispose();
		}
		
		//--------------- ctrl ---------------//
		
		//------------ get / set -------------//
		
		public function get source():IDraggle
		{
			return _source;
		}
		
		//------- handlers / callbacks -------//
		
		private function addedToStageHandler(e:Event):void
		{
			createSnapshot();
		}
		
		private function removedToStageHandler(e:Event):void
		{
			dispose();
		}
	}
}