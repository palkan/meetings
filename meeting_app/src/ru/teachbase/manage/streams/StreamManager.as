package ru.teachbase.manage.streams {
import flash.events.AsyncErrorEvent;
import flash.events.ErrorEvent;
import flash.events.IOErrorEvent;
import flash.events.NetStatusEvent;
import flash.net.NetStream;

import mx.core.EventPriority;
import mx.rpc.Responder;

import ru.teachbase.constants.NetStreamStatusCodes;
import ru.teachbase.constants.PacketType;
import ru.teachbase.events.GlobalEvent;
import ru.teachbase.manage.*;
import ru.teachbase.manage.rtmp.RTMPListener;
import ru.teachbase.manage.rtmp.events.RTMPEvent;
import ru.teachbase.manage.session.model.Meeting;
import ru.teachbase.manage.streams.model.NetStreamClient;
import ru.teachbase.manage.streams.model.StreamData;
import ru.teachbase.model.App;
import ru.teachbase.utils.shortcuts.debug;
import ru.teachbase.utils.shortcuts.error;
import ru.teachbase.utils.shortcuts.rtmp_call;
import ru.teachbase.utils.shortcuts.rtmp_history;
import ru.teachbase.utils.shortcuts.warning;

/**
 * @author Webils (created: Mar 2, 2012)
 */

public dynamic class StreamManager extends Manager {
    private const RESTART_STREAM_TIME:int = 2000;

    private const _listener:RTMPListener = new RTMPListener(PacketType.STREAM);

    private var _model:Meeting;

    //------------ constructor ------------//

    public function StreamManager(registered:Boolean = false) {
        super(registered);
        new StreamData();
    }

    //------------ initialize ------------//

    override protected function initialize():void {

        _model = App.meeting;

        _listener.initialize();
        _listener.addEventListener(RTMPEvent.DATA, handleMessage);

        GlobalEvent.addEventListener(GlobalEvent.USER_LEAVE, onUserLeave);

        rtmp_history(PacketType.STREAM, new Responder(handleHistory, function (...args):void {
            error("Failed to load streams history");
            _failed = true;
        }));
    }


    //------------ API -------------------//

    public function closeRemoteStream(uid:Number):void{

    }

    override public function dispose():void {
        _initialized = false;
    }

    //------------ handlers --------------//


    private function handleHistory(v:Array):void {
        if (v && v.length) {
            for each (var str:StreamData in v) {
                addStream(str);
            }
        }

        _listener.readyToReceive = true;
        _initialized = true;
    }


    protected function handleMessage(e:RTMPEvent):void {

        var stream:StreamData = e.packet.data as StreamData;

        if (!stream) return;

        if (_model.usersByID[stream.user_id] && !_model.streamsByName[stream.name]) {
            addStream(stream);
        }
    }


    protected function onUserLeave(event:GlobalEvent):void {
        removeStreamsByUser(event.value.sid);
    }

    private function streamErrorHandler(e:ErrorEvent):void {
        warning("Stream error " + e.type + " - " + e.text);
    }

    private function streamPlayOnStatusHandler(e:NetStatusEvent):void {

        debug("Stream status:", (e.target as NetStream).info.resourceName, e.info.code);

        const data:StreamData = ((e.target as NetStream).client as NetStreamClient).data as StreamData;

        switch (e.info.code) {
            case NetStreamStatusCodes.PLAY_FAILED:
                warning("Failed to subscribe to stream", data.name);
                checkFailedStream(data);
                break;
            case NetStreamStatusCodes.NOT_FOUND:
                warning("Stream not found", data.name);
                removeStreamByName(data.name);
                break;
            case NetStreamStatusCodes.PLAY_START:
                var ns:NetStream = e.target as NetStream;
                _model.streamList.addItem(ns);
                break;
            case NetStreamStatusCodes.PLAY_STOP:
                removeStreamByName(data.name);
                break;
        }
    }

    //--------------- ctrl ---------------//

    private function addStream(stream:StreamData):void {
        var ns:NetStream = new NetStream(App.rtmp.getMediaStreamsConnection());

        ns.addEventListener(NetStatusEvent.NET_STATUS, streamPlayOnStatusHandler, false, EventPriority.DEFAULT_HANDLER);

        var ns_client:NetStreamClient = new NetStreamClient(stream);

        ns.client = ns_client;

        _model.streamsByName[stream.name] = ns;

        ns.addEventListener(AsyncErrorEvent.ASYNC_ERROR, streamErrorHandler);
        ns.addEventListener(IOErrorEvent.IO_ERROR, streamErrorHandler);

        ns.bufferTime = 0;
        ns.backBufferTime = 0;
        ns.play(stream.name);
    }

    private function removeStreamsByUser(uid:Number):void{



    }

    private function removeStreamByName(name:String):void{

        if(!_model.streamsByName[name]) return;

        var ns:NetStream = _model.streamsByName[name] as NetStream;
        ns.dispose();
        ns.removeEventListener(AsyncErrorEvent.ASYNC_ERROR, streamErrorHandler);
        ns.removeEventListener(IOErrorEvent.IO_ERROR, streamErrorHandler);
        ns.removeEventListener(NetStatusEvent.NET_STATUS, streamPlayOnStatusHandler);

        delete _model.streamsByName[name];

        const ind:int = _model.streamList.getItemIndex(ns);

        (ind > -1) && _model.streamList.removeItemAt(ind);

    }

    private function removeAllStreams():void{

        for each(var ns:NetStream in _model.streamList){
            delete _model.streamsByName[(ns.client as NetStreamClient).data.name];
            ns.dispose();
        }

        _model.streamList.removeAll();
    }

    private function checkFailedStream(data:StreamData):void {
            removeStreamByName(data.name);
            addStream(data);
    }

}
}
