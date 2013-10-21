/**
 * User: palkan
 * Date: 10/17/13
 * Time: 11:24 AM
 */
package ru.teachbase.manage.streams {
import com.mangui.HLS.HLS;

import flash.net.NetStream;

import ru.teachbase.manage.streams.model.NetStreamClient;
import ru.teachbase.model.App;

public class RecordStreamManager extends StreamManager {


    public function RecordStreamManager(registered:Boolean = false) {
        super(registered);
    }

    override protected function initialize(reinit:Boolean = false):void {

        _model = App.meeting;
        _initialized = true;
    }

    override public function clear():void{
        _initialized = false;
        _failed = false;
    }


    public function addHLSStream(ns:NetStream):void {

        _model.streamsByName[(ns.client as NetStreamClient).data.name] = ns;

        _model.streamList.addItem(ns);
    }


    public function removeHLSStream(hls:HLS):void {

        if (!hls) return;

        var ns:NetStream = hls.stream;

        delete _model.streamsByName[(ns.client as NetStreamClient).data.name];

        const ind:int = _model.streamList.source.indexOf(ns);

        (ind > -1) && _model.streamList.removeItemAt(ind);
    }


    public function removeHLSStreams():void {
        for each(var ns:NetStream in _model.streamList)
            delete _model.streamsByName[(ns.client as NetStreamClient).data.name];

        _model.streamList.removeAll();
    }


}
}
