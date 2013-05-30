package ru.teachbase.module.board
{
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.filters.DropShadowFilter;
import flash.geom.Rectangle;

import mx.core.IInvalidating;

import ru.teachbase.behaviours.interfaces.INotDraggle;
import ru.teachbase.module.board.components.Page;
import ru.teachbase.module.board.figures.FigureManager;
import ru.teachbase.module.board.style.FillStyle;
import ru.teachbase.module.board.style.StrokeStyle;

import spark.components.ResizeMode;
import spark.core.SpriteVisualElement;

/**
	 * @author Aleksandr Kozlovskij (created: Mar 20, 2012)
	 * 210 × 297 mm
	 */
	public final class BoardCanvas extends SpriteVisualElement implements INotDraggle
	{
		// A4 LANDSCAPE
		private static const WIDTH_SM:int = 300;
		private static const HEIGHT_SM:int = 225;
		private var _ratio:Number = WIDTH_SM / HEIGHT_SM;
		
		private var _maxCanvasWidth:Number = NaN;
		
		private const canvasBackground:Bitmap = new Bitmap(new BitmapData(1, 1, true, 0xF0FFFF));
		private const canvasMask:Bitmap = new Bitmap(new BitmapData(1, 1, false, 0xFFFFFF));
		private const outlineContainer:Sprite = new Sprite();
		private var _background:BitmapData;
		
		public var cursorContainer:Sprite = new Sprite();
		
		
		/**
		 * Current page
		 */		
		
		public var page:Page;
		
		/**
		 * Current page id 
		 */		
		
		public var page_id:int = 0;
		
		
		private var _pages:Object = new Object(); 
		
		public const formatBounds:Rectangle = new Rectangle();
		
		public const stroke:StrokeStyle = new StrokeStyle();
		public const fill:FillStyle = new FillStyle();
		
		public const marginLeft:int = 0;
		public const marginTop:int = 0;
		[Bindable]
		public var manager:FigureManager;
		
		
		private var _editable:Boolean;
		
		
		//------------ constructor ------------//
		
		public function BoardCanvas()
		{
			super();
			
			buttonMode =
			mouseChildren =
			mouseEnabled = true;
			useHandCursor = false;
			doubleClickEnabled = true;
			resizeMode = ResizeMode.SCALE;
			
			
			
			
			addChild(canvasMask);
			addChild(canvasBackground);
			
			var _page:Page = new Page(this,canvasMask);
			_pages[_page.pageId] = _page;
					
			page = _page;
			
			canvasBackground.filters = [new DropShadowFilter(3, 45, 0, .4, 3, 3)];
			
			
			
			initialize();
			addChild(cursorContainer);	
			
			// default styles:
			stroke.thickness = 1;
			stroke.alpha = 1;
			
		}
		
		
		public function dispose():void{
			
			_pages = null;
			
			
		}
		
		
		private function initialize():void
		{
			page.show();
		}
		
		
		
		public function gotoPage(id:int):void{
			
			//removeChild(figureContainer);
			page.hide();
			
			
			if(_pages[id] == undefined){
				_pages[id] = new Page(this,canvasMask,id);
			}
			
			page = _pages[id];
			alignObjects();
			page.show();
			
			setChildIndex(cursorContainer,numChildren-1);
			
			manager && manager.history.clear();
			
		}
		
		
		
		
		
	
		
				
		//--------------- ctrl ---------------//
		
		override protected function invalidateParentSizeAndDisplayList():void
		{
			super.invalidateParentSizeAndDisplayList();
			
			if(!includeInLayout) return;
			
			var p:IInvalidating = parent as IInvalidating;
			if(!p) return;
			
			const old:Rectangle = formatBounds.clone();
			calculateFormatBounds();
			// size changed?
			if(old.width != formatBounds.width || old.height != formatBounds.height)
			{
				resizeObjects();
			}
			alignObjects();
		}
		
		private function resizeObjects():void
		{
			// background & mask:
			canvasBackground.width = canvasMask.width = formatBounds.width;
			canvasBackground.height = canvasMask.height = formatBounds.height;
			// canvas:
			manager && manager.scaleRelativeCanvasWidth(formatBounds.width);
			
			
			
		}
		
		private function redrawBackground():void
		{	
			if (_opaqueBackground != null) {
				canvasBackground.bitmapData.setPixel(0, 0, uint(_opaqueBackground));
			}else{
				canvasBackground.bitmapData = _background ? _background : new BitmapData(1,1,true, 0xFFFFFF);
				resizeObjects();
			}
		}
		
		public function set background(bd:BitmapData):void{
			_background = bd;
			redrawBackground();
		}
		
		private function alignObjects():void
		{
			// background & mask & canvas:
			canvasBackground.x = canvasMask.x = page.x = cursorContainer.x = formatBounds.x;
			canvasBackground.y = canvasMask.y = page.y = cursorContainer.y = formatBounds.y;
			
			/*if(hasEventListener(MouseEvent.CLICK))
				selectedItems = _selectedItems;*/
		}
		
		private function actualizeFormatBounds():void
		{
			formatBounds.setTo(x+marginLeft, y+marginTop, width-2*marginLeft, height-2*marginTop);
		}
		
		
		private function calculateFormatBounds():void
		{
			actualizeFormatBounds();
			
			const original:Rectangle = formatBounds.clone();
			
			if(!isNaN(_maxCanvasWidth) && _maxCanvasWidth < formatBounds.width){
				
				formatBounds.width = _maxCanvasWidth;
				
			}
			
			const ratio:Number = formatBounds.width / formatBounds.height;
			
			if(_ratio == ratio) return;
			
			if(_ratio < ratio)
				formatBounds.width = formatBounds.height * _ratio;
			else
			if(_ratio > ratio)
				formatBounds.height = formatBounds.width / _ratio;
			
			
			// align by center:
			formatBounds.x = int((original.width - formatBounds.width) / 2) + marginLeft;
			formatBounds.y = int((original.height - formatBounds.height) / 2) + marginTop;
			
		}
		
		
		
		public function getPageSprite(id:int):Page{
			
			if(_pages[id] == undefined){
				_pages[id]  = new Page(this,canvasMask,id);
			}

			return (_pages[id] as Page);
			
		}
		
		
		
		//------------ get / set -------------//
		
		private var _opaqueBackground:Object;
			
		override public function set opaqueBackground(value:Object):void
		{
			//if(uint(super.opaqueBackground) == uint(value))
			//	return;
			
			_opaqueBackground = value;
			redrawBackground();
		}
		
		/**
		 * Using for x-coords-conversations
		 */		
		override public function get mouseX():Number
		{
			return page.figureContainer.mouseX;
		}
		
		/**
		 * Using for y-coords-conversations
		 */		
		override public function get mouseY():Number
		{
			return page.figureContainer.mouseY;
		}

		public function get editable():Boolean
		{
			return _editable;
		}

		public function set editable(value:Boolean):void
		{
			_editable = value;
			
			if(!value)
				manager.currentInstrument = null;
			
		}

		public function get ratio():Number
		{
			return _ratio;
		}

		public function set ratio(value:Number):void
		{
			_ratio = value;
			invalidateParentSizeAndDisplayList();
		}

		public function get maxCanvasWidth():Number
		{
			return _maxCanvasWidth;
		}

		public function set maxCanvasWidth(value:Number):void
		{
			_maxCanvasWidth = value;
			invalidateParentSizeAndDisplayList();
		}
		
		
		
		//------- handlers / callbacks -------//
		
	}
}