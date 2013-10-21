/**
 * User: palkan
 * Date: 10/21/13
 * Time: 11:56 AM
 */
package ru.teachbase.manage.streams.model {
import com.mangui.HLS.HLS;

public class StreamMapData extends StreamData {

    private var _start_ts:Number=0;
    private var _finish_ts:Number=0;
    private var _hls:HLS;

    public function StreamMapData(start:Number,finish:Number) {
        super();
        _start_ts = start;
        _finish_ts = finish;
    }

    public function get start_ts():Number {
        return _start_ts;
    }

    public function get finish_ts():Number {
        return _finish_ts;
    }

    public function set hls(value:HLS):void{
        _hls = value;
    }

    public function get hls():HLS {
        return _hls;
    }

}

}
