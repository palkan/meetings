/**
 * User: palkan
 * Date: 8/19/13
 * Time: 2:10 PM
 */
package ru.teachbase.components.board.model {
import flash.geom.Point;

import ru.teachbase.utils.system.registerClazzAlias;

public class BoardUpdateData {

    registerClazzAlias(BoardUpdateData);
    registerClazzAlias(Point);

    private var _action:String;
    private var _fid:String;
    private var _data:*;

    public function BoardUpdateData(action:String = "", fid:String = "", data:* = null){
        _action = action;
        _fid = fid;
        _data = data;
    }

    public function get fid():String {
        return _fid;
    }

    public function set fid(value:String):void {
        _fid = value;
    }

    public function get action():String {
        return _action;
    }

    public function set action(value:String):void {
        _action = value;
    }

    public function get data():* {
        return _data;
    }

    public function set data(value:*):void {
        _data = value;
    }
}
}
