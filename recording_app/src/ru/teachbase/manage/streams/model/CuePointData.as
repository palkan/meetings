/**
 * User: palkan
 * Date: 10/21/13
 * Time: 1:40 PM
 */
package ru.teachbase.manage.streams.model {
public class CuePointData {

    public static const START:String = "cue:start";
    public static const STOP:String = "cue:stop";

    private var _ts:Number;
    private var _kind:String;
    private var _data:StreamMapData;

    /**
     *
     * @param ts
     * @param kind
     * @param data
     */

    public function CuePointData(ts:Number,kind:String,data:StreamMapData){
        _kind = kind;
        _ts = ts;
        _data = data;
    }

    /**
     *
     */

    public function get kind():String {
        return _kind;
    }

    /**
     *
     */

    public function get data():StreamMapData {
        return _data;
    }

    /**
     *
     */
    public function get ts():Number {
        return _ts;
    }
}
}
