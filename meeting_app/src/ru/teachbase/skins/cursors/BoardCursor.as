package ru.teachbase.skins.cursors
{
import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.filters.DropShadowFilter;

public class BoardCursor extends Sprite
	{
		
		public static var icon:DisplayObject;
		private static const filter:DropShadowFilter = new DropShadowFilter(3, 45, 0, .4, 3, 3);
		
		
		public function BoardCursor()
		{
			super();
			icon.x = 0;//s-icon.width;
			icon.y = -icon.height;
			icon.filters = [filter];
			this.addChild(icon);
		}
	}
}