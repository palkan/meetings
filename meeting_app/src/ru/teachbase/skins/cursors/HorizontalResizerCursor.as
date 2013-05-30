package ru.teachbase.skins.cursors
{
import flash.display.DisplayObject;
import flash.display.Sprite;

public class HorizontalResizerCursor extends Sprite
	{
		
		
		public static var icon:DisplayObject;
		
		
		public function HorizontalResizerCursor()
		{
			super();
			icon.x = -icon.width/2;
			icon.y = -icon.height/2;
			this.addChild(icon);
		}
	}
}