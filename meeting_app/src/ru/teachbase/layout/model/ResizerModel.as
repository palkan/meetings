/**
 * User: palkan
 * Date: 5/27/13
 * Time: 1:48 PM
 */
package ru.teachbase.layout.model {
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.geom.Point;
import flash.geom.Rectangle;

public class ResizerModel{

    private var _key:String;

    public var position:Point;
    public var param:Number;
    public var groupParam:Number;
    public var gap:Number;
    public var dragBounds:Rectangle;
    public var direction:uint;

    public function ResizerModel(key:String) {
        _key = key;
    }

    public function get key():String {
        return _key;
    }


}
}
