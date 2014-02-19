/**
 * User: palkan
 * Date: 2/19/14
 * Time: 4:07 PM
 */
package ru.teachbase.manage.livecursor {
import flash.display.DisplayObjectContainer;
import flash.geom.Point;

public class SimpleCursorManager {

    private var _cursor:LiveCursor;

    public function SimpleCursorManager(container:DisplayObjectContainer) {
        _cursor = new LiveCursor(0);
        container.addChild(_cursor);
    }

    public function posCursor(point:Point):void{
        _cursor.move(point.x, point.y);
    }
}
}
