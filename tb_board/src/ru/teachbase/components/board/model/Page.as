package ru.teachbase.components.board.model
{
import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.Sprite;
import flash.filters.DropShadowFilter;

public class Page
	{
		
		private var _container:DisplayObjectContainer;
		
		private var _mask:DisplayObject;
		
		private var _pageId:int;
		
		private var _x:Number = 0;
		private var _y:Number = 0;
		
		
		public var figureContainer:Sprite;
		
		public var textContainer:Sprite;
		
		
		public function Page(container:DisplayObjectContainer, mask:DisplayObject,page:int = 0)
		{
			_container = container;
			_mask = mask;
			_pageId = page;
			textContainer = new Sprite();
			
			figureContainer = new Sprite(); 
			figureContainer.filters = [new DropShadowFilter(3, 45, 0, .4, 3, 3)];
			figureContainer.mask = _mask;
			textContainer.mask = _mask;
		}
		
		
		
		public function show():void{
			_container.addChild(figureContainer);
            _container.addChild(textContainer);
		}
		
		
		
		public function hide():void{
			
			_container.removeChild(textContainer);
			_container.removeChild(figureContainer);
			
		}

		public function get pageId():int
		{
			return _pageId;
		}

		public function get x():Number
		{
			return _x;
		}

		public function set x(value:Number):void
		{
			figureContainer.x = value;
			textContainer.x = value;
			_x = value;
		}

		public function get y():Number
		{
			return _y;
		}

		public function set y(value:Number):void
		{
			figureContainer.y = value;
			textContainer.y = value;
			_y = value;
		}
		
		
		
	}
}