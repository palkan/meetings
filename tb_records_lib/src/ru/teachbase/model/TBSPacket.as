/**
 * User: palkan
 * Date: 10/15/13
 * Time: 3:56 PM
 */
package ru.teachbase.model {
public class TBSPacket {

    private var _ts:Number;
    private var _data:*;

    public function TBSPacket(ts:Number, data:*) {
        _ts = ts;
        _data = data;
    }

    public function get ts():Number {
        return _ts;
    }

    public function get data():* {
        return _data;
    }
}
}
