package ru.teachbase.features.live.mouse
{
import flash.display.DisplayObjectContainer;
import flash.geom.Point;

public class SimpleLiveCursorManager
	{
		private var _cursor:LiveCursor;
		
		public function SimpleLiveCursorManager(container:DisplayObjectContainer)
		{
			_cursor = new LiveCursor(0);
			container.addChild(_cursor);
		}
		
		public function posCursor(point:Point):void{
			_cursor.move(point.x, point.y);
		}
	}
}