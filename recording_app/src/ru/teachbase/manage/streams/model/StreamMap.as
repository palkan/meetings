package ru.teachbase.manage.streams.model {
import ru.teachbase.manage.rtmp.model.Packet;

/**
 * @author palkan
 */
public class StreamMap {

    private const _elements:Vector.<StreamMapData> = new <StreamMapData>[];

    //------------ constructor ------------//

    /**
     * Creates new stream map
     */

    public function StreamMap() {

    }

    public function dispose():void {
        _elements.length = 0;
    }


    //------------ initialize ------------//

    //--------------- ctrl ---------------//


    public function add(data:StreamMapData):void{

        if (!_elements.length) _elements.push(data);
        else {

            var last:Boolean;

            for each(var s:StreamMapData in _elements) {

                last = false;

                if (s.start_ts > data.start_ts) break;

                if (s.finish_ts > data.finish_ts) break;

                last = true;
            }

            if (last) _elements.push(data);
            else if (ind == 0) {
                _elements.unshift(data);
            } else {
                const ind:int = _elements.indexOf(s);
                _elements.splice(ind - 1, 0, data);
            }

        }
    }

    /**
     *
     * Returns streams data which active at the <code>time</code>
     *
     * @param time
     * @return
     */

    public function find(time:Number):Vector.<StreamMapData>{

        var list:Vector.<StreamMapData> = new <StreamMapData>[];

        for each(var s:StreamMapData in _elements){

            if(s.start_ts>time) break;

            if(s.start_ts<=time && s.finish_ts>time) list.push(s);

        }

        return list;
    }


    public function nextCuePoint(time:Number):CuePointData{

        var _kind:String;
        var _data:StreamMapData;
        var _ts:Number;
        var _delta:Number = int.MAX_VALUE;

        for each(var s:StreamMapData in _elements){

           if(s.start_ts-time>0 && s.start_ts-time < _delta){
              _delta = s.start_ts-time;
              _data = s;
              _kind = CuePointData.START;
              _ts = s.start_ts;
           }

           if(s.finish_ts-time>0 && s.finish_ts-time < _delta){
              _delta = s.finish_ts-time;
              _data = s;
              _kind = CuePointData.STOP;
              _ts = s.finish_ts;
           }

        }

        return _data ? new CuePointData(_ts,_kind,_data) : null;
    }


    public function get size():int{
        return _elements.length;
    }

}
}