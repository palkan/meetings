package ru.teachbase.manage.streams {
import flash.events.AsyncErrorEvent;
import flash.events.ErrorEvent;
import flash.events.IOErrorEvent;
import flash.events.NetStatusEvent;
import flash.net.NetStream;

import mx.core.EventPriority;
import mx.events.CollectionEvent;
import mx.events.CollectionEventKind;
import mx.rpc.Responder;

import ru.teachbase.components.notifications.Notification;

import ru.teachbase.constants.NetStreamStatusCodes;
import ru.teachbase.constants.PacketType;
import ru.teachbase.constants.QualityFPSBitrate;
import ru.teachbase.events.GlobalEvent;
import ru.teachbase.manage.*;
import ru.teachbase.manage.rtmp.RTMPListener;
import ru.teachbase.manage.rtmp.events.RTMPEvent;
import ru.teachbase.manage.session.model.Meeting;
import ru.teachbase.manage.streams.model.NetStreamClient;
import ru.teachbase.manage.streams.model.StreamData;
import ru.teachbase.model.App;
import ru.teachbase.net.stats.RTMPWatch;
import ru.teachbase.utils.CameraQuality;
import ru.teachbase.utils.CameraUtils;
import ru.teachbase.utils.CameraUtils;
import ru.teachbase.utils.shortcuts.debug;
import ru.teachbase.utils.shortcuts.error;
import ru.teachbase.utils.shortcuts.notify;
import ru.teachbase.utils.shortcuts.rtmp_call;
import ru.teachbase.utils.shortcuts.rtmp_history;
import ru.teachbase.utils.shortcuts.rtmp_send;
import ru.teachbase.utils.shortcuts.translate;
import ru.teachbase.utils.shortcuts.warning;

/**
 * @author Webils (created: Mar 2, 2012)
 */

public dynamic class StreamManager extends Manager {

    private const listener:RTMPListener = new RTMPListener(PacketType.STREAM);

    /**
     *  Reserved bandwidth for audio-only streams.
     */

    private const AUDIO_BW:int = 20;

    private var _model:Meeting;

    private var _bandwidth:Number = 0;
    private var _bw_per_stream:Number = 0;

    //------------ constructor ------------//

    public function StreamManager(registered:Boolean = false) {
        super(registered);
        new StreamData();
    }

    //------------ initialize ------------//

    override protected function initialize(reinit:Boolean = false):void {

        _model = App.meeting;

        listener.initialize();
        listener.addEventListener(RTMPEvent.DATA, handleMessage);

        GlobalEvent.addEventListener(GlobalEvent.USER_LEAVE, onUserLeave);

        rtmp_history(PacketType.STREAM, new Responder(handleHistory, function (...args):void {
            error("Failed to load streams history");
            _failed = true;
        }));

        _model.streamList.addEventListener(CollectionEvent.COLLECTION_CHANGE, streamsUpdated);
    }


    override public function clear():void{
        super.clear();
        listener.dispose();
        removeAllStreams();
        listener.removeEventListener(RTMPEvent.DATA, handleMessage);
        GlobalEvent.removeEventListener(GlobalEvent.USER_LEAVE, onUserLeave);
    }


    //------------ API -------------------//

    public function closeRemoteStream(uid:Number, type:uint = 0):void{

        rtmp_send(PacketType.PUBLISH,{action:"close", type:type},uid,null,false);

    }


    /**
     *
     * Setup available incoming bandwidth and recalculate per stream bandwidth.
     *
     * @param bw   bw = 0 assumes unlimited bandwidth.
     */


    public function setupBandwidth(bw:Number):void{

        _bandwidth = bw;
        calculatePerStreamBW();

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

        listener.readyToReceive = true;
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


    private function streamsUpdated(event:CollectionEvent):void{

        switch(event.kind){
            case CollectionEventKind.REMOVE:
            case CollectionEventKind.UPDATE:
            case CollectionEventKind.RESET:
                calculatePerStreamBW();
                break;
        }

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
            case NetStreamStatusCodes.PLAY_START:{
                var ns:NetStream = e.target as NetStream;
                _model.streamList.addItem(ns);

                var _watcher:RTMPWatch = new RTMPWatch(ns);
                App.rtmpMedia.stats.registerInput(_watcher);
                _watcher.watch();
                (ns.client as NetStreamClient).watcher = _watcher;

                break;
            }
            case NetStreamStatusCodes.PLAY_STOP:
                removeStreamByName(data.name);
                break;
        }
    }

    //--------------- ctrl ---------------//

    private function addStream(stream:StreamData):void {
        var ns:NetStream = new NetStream(App.rtmpMedia.connection);

        ns.addEventListener(NetStatusEvent.NET_STATUS, streamPlayOnStatusHandler, false, EventPriority.DEFAULT_HANDLER);

        var ns_client:NetStreamClient = new NetStreamClient(stream);

        ns.client = ns_client;

        _model.streamsByName[stream.name] = ns;

        ns.addEventListener(AsyncErrorEvent.ASYNC_ERROR, streamErrorHandler);
        ns.addEventListener(IOErrorEvent.IO_ERROR, streamErrorHandler);

        ns.bufferTime = 0;
        ns.backBufferTime = 0;
        ns.play(stream.name,0,false,App.user.sid.toString());
    }

    private function removeStreamsByUser(uid:Number):void{



    }

    private function removeStreamByName(name:String):void{

        if(!_model.streamsByName[name]) return;

        var ns:NetStream = _model.streamsByName[name] as NetStream;

        const watcher:RTMPWatch = (ns.client as NetStreamClient).watcher;
        watcher && watcher.unwatch();

        App.rtmpMedia.stats.unregisterInput(watcher);

        ns.dispose();
        ns.removeEventListener(AsyncErrorEvent.ASYNC_ERROR, streamErrorHandler);
        ns.removeEventListener(IOErrorEvent.IO_ERROR, streamErrorHandler);
        ns.removeEventListener(NetStatusEvent.NET_STATUS, streamPlayOnStatusHandler);


        delete _model.streamsByName[name];

        const ind:int = _model.streamList.getItemIndex(ns);

        (ind > -1) && _model.streamList.removeItemAt(ind);

    }

    private function removeAllStreams():void{

        for each(var ns:NetStream in _model.streamList)
            delete _model.streamsByName[(ns.client as NetStreamClient).data.name];


        _model.streamList.removeAll();
    }

    private function checkFailedStream(data:StreamData):void {
            removeStreamByName(data.name);
            addStream(data);
    }


    private function calculatePerStreamBW():void{

        const videoStreams:Array = _model.streamList.source;

        if(_bandwidth <= 0){
            _bw_per_stream = 0;

            videoStreams.forEach(
                    function(ns:NetStream,...args):void{
                        (ns.client.metadata['fps'] != CameraUtils.DEFAULT_FPS) && ns.receiveVideo(true);
                    }
            );

            return;
        }


        const videoCount:int = videoStreams.filter(videoFilter).length;

        if(!videoCount) return;

        const size:int = _model.streamList.source.length;

        _bw_per_stream =  Math.max((_bandwidth - (size - videoCount)*AUDIO_BW) / videoCount, AUDIO_BW);


        var decreasedFlag:Boolean = false;

        videoStreams.forEach(

                function(ns:NetStream,...args):void{

                    const client:NetStreamClient = ns.client as NetStreamClient;

                    const fps:int = QualityFPSBitrate.fpsByBitrateAndQuality(_bw_per_stream,client.metadata['quality']);

                    if(fps == client.metadata['fps']) return;

                    warning('Change fps from '+client.metadata['fps']+' to '+fps+' in stream '+client.data.name);

                    if(fps < client.metadata['fps']) decreasedFlag = true;

                    client.metadata['fps'] = fps;


                    if(fps === CameraUtils.DEFAULT_FPS)  ns.receiveVideo(true);
                    else if(fps>0)  ns.receiveVideoFPS(fps);
                    else            ns.receiveVideo(false);
                }
        )

        decreasedFlag && notify(new Notification(translate('bw_instream_low_fps','notifications')));

    }


    private function videoFilter(ns:NetStream,...args):Boolean{

        return (ns.client as NetStreamClient).hasVideo && !ns.client.metadata['paused'];

    }


}
}
