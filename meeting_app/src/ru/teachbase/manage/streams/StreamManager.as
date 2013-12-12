package ru.teachbase.manage.streams {
import flash.events.AsyncErrorEvent;
import flash.events.ErrorEvent;
import flash.events.Event;
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
import ru.teachbase.utils.CameraUtils;
import ru.teachbase.utils.shortcuts.debug;
import ru.teachbase.utils.shortcuts.error;
import ru.teachbase.utils.shortcuts.notify;
import ru.teachbase.utils.shortcuts.rtmp_history;
import ru.teachbase.utils.shortcuts.rtmp_send;
import ru.teachbase.utils.shortcuts.translate;
import ru.teachbase.utils.shortcuts.warning;

/**
 * @author Webils (created: Mar 2, 2012)
 */

public dynamic class StreamManager extends Manager {

    protected const listener:RTMPListener = new RTMPListener(PacketType.STREAM);

    /**
     *  Reserved bandwidth for audio-only streams.
     */

    private const AUDIO_BW:int = 20;

    protected var _model:Meeting;

    private var _bandwidth:Number = 0;
    private var _bw_per_stream:Number = 0;

    /**
     * Temporary storage for <i>probably</i> dead streams
     */

    private var _to_remove:Object = {};

    /**
     * List of initial streams to start after load complete
     */

    private var _to_start:Vector.<StreamData>;

    /**
     * Define whether all streams from  <i>_to_start</i> list was started.
     */

    protected var _started:Boolean = false;

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
        _started = false;
        listener.dispose();
        removeAllStreams();
        listener.removeEventListener(RTMPEvent.DATA, handleMessage);
        GlobalEvent.removeEventListener(GlobalEvent.USER_LEAVE, onUserLeave);
    }


    //------------ API -------------------//


    /**
     * Call this function when all managers are ready to subscribe to streams.
     */

    public function loadStreams():void{

        if(!_to_start || !_to_start.length)
            _started = true;
        else
            addStream(_to_start.pop());
    }


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
       // calculatePerStreamBW();

    }


    override public function dispose():void {
        _initialized = false;
    }

    //------------ handlers --------------//


    protected function playTimeout(netstream:NetStream):void{
       const data:StreamData = netstream.client.data;
        if(!data) return;
        removeStreamByName(data.name);
        disposeNetStream(netstream);
        addStream(data);
    }


    protected function playStopTimeout(netstream:NetStream):void{
        disposeNetStream(netstream);
        _to_start.length && addStream(_to_start.pop());
    }


    protected function handleHistory(v:Array):void {
        _to_start = new Vector.<StreamData>();
        if (v && v.length) {

            for each (var str:StreamData in v) {
                _to_start.push(str);
            }
        }

        listener.readyToReceive = true;
        _initialized = true;
    }


    protected function handleMessage(e:RTMPEvent):void {

        var stream:StreamData = e.packet.data as StreamData;

        if (!stream) return;

        if (_model.usersByID[stream.user_id] && !_model.streamsByName[stream.name]) {
            if(_started)
                addStream(stream);
            else{
                !_to_start && (_to_start = new <StreamData>[]);
                _to_start.push(stream);
            }
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
                //calculatePerStreamBW();
                break;
        }

    }

    private function streamLooksDeadHandler(e:Event):void{
        const watcher:RTMPWatch = e.target as RTMPWatch;
        warning("Stream looks dead", watcher.client.data);
        watcher.unwatch();
        watcher.watch();
       // checkFailedStream(watcher.client.data);
    }

    private function streamErrorHandler(e:ErrorEvent):void {
        warning("Stream error " + e.type + " - " + e.text);
    }

    private function streamPlayOnStatusHandler(e:NetStatusEvent):void {

        const client:NetStreamClient = (e.target as NetStream).client as NetStreamClient;
        const data:StreamData = client.data as StreamData;

        debug("Stream status:", e.info.code, data);

        switch (e.info.code) {
            case NetStreamStatusCodes.BUFFER_EMPTY:
                client.__buffer_empty_ts = (new Date()).getTime();
                break;
            case NetStreamStatusCodes.BUFFER_FULL:
                var __now:Number = (new Date().getTime());
                client.__buffer_lag = client.__buffer_lag||0;

                if(client.__buffer_empty_ts) client.__buffer_lag += (__now-client.__buffer_empty_ts);

                debug("Stream buffer lag:"+client.__buffer_lag);

                if(client.__stream_start_ts){
                    debug("Stream time: " + (e.target as NetStream).time+"; real time: " + (__now - client.__stream_start_ts));
                }
                break;
            case NetStreamStatusCodes.PLAY_FAILED:
                warning("Failed to subscribe to stream", data.name);
                disposeNetStream(e.target as NetStream);
                //!client.metadata.killed && checkFailedStream(data);
                removeStreamByName(data.name);
                _to_start.length && addStream(_to_start.pop());
                break;
            case NetStreamStatusCodes.NOT_FOUND:
                warning("Stream not found", data.name);
                disposeNetStream(e.target as NetStream);
                removeStreamByName(data.name);
                if(!_started && !_to_start.length)
                    _started = true;
                else if(!_started || _to_start.length) addStream(_to_start.pop());
                break;
            case NetStreamStatusCodes.PLAY_START:{

                if(_to_remove[data.name]){
                    removeFromList(_to_remove[data.name]);
                    delete _to_remove[data.name];
                }

           //     client.tid && clearTimeout(client.tid);

                var ns:NetStream = e.target as NetStream;
                _model.streamList.addItem(ns);

                /*var _watcher:RTMPWatch = new RTMPWatch(ns);
                App.rtmpMedia.stats.registerInput(_watcher);

                _watcher.addEventListener(Event.CLEAR, streamLooksDeadHandler);

                _watcher.watch();
                (ns.client as NetStreamClient).watcher = _watcher;
                */

                client.__stream_start_ts = (new Date()).getTime();

                if(!_started && !_to_start.length)
                    _started = true;
                else if(!_started || _to_start.length) addStream(_to_start.pop());

                break;
            }
            case NetStreamStatusCodes.PLAY_STOP:
                disposeNetStream(e.target as NetStream);
                _to_start.length && addStream(_to_start.pop());
                break;
        }
    }

    //--------------- ctrl ---------------//

    protected function addStream(stream:StreamData):void {
        var ns:NetStream = new NetStream(App.rtmp.connection);//App.rtmpMedia.connection);

        ns.addEventListener(NetStatusEvent.NET_STATUS, streamPlayOnStatusHandler, false, EventPriority.DEFAULT_HANDLER);

        var ns_client:NetStreamClient = new NetStreamClient(stream);

        ns.client = ns_client;

        _model.streamsByName[stream.name] = ns;

        ns.addEventListener(AsyncErrorEvent.ASYNC_ERROR, streamErrorHandler);
        ns.addEventListener(IOErrorEvent.IO_ERROR, streamErrorHandler);

        ns.bufferTime = 0;
        ns.bufferTimeMax = 1;

        ns.backBufferTime = 0;

        debug("Stream play: "+stream.name);

  //      ns.client.tid = setTimeout(lambda(playTimeout,ns),10000);
        ns.play(stream.name,0,false,App.user.sid.toString());
    }

    private function removeStreamsByUser(uid:Number):void{

        for each(var ns:NetStream in _model.streamsByName){

            var client:NetStreamClient = ns.client as NetStreamClient;

            if(client.data.user_id == uid) removeStreamByName(client.data.name);

        }

    }

    /**
     *
     * @param name
     * @param commit  If <i>true</i> then call <i>removeFromList</i>; else add stream to <i>_toRemove</i> hash.
     */

    private function removeStreamByName(name:String, commit:Boolean = true):void{

        if(_to_remove[name]){
            removeFromList(_to_remove[name]);
            delete _to_remove[name];
        }

        if(!_model.streamsByName[name]) return;

        var ns:NetStream = _model.streamsByName[name] as NetStream;

        /*const watcher:RTMPWatch = (ns.client as NetStreamClient).watcher;
        watcher && watcher.unwatch();
        watcher && watcher.removeEventListener(Event.CLEAR, streamLooksDeadHandler);

        App.rtmpMedia.stats.unregisterInput(watcher);
        */

        if(!commit){
          //  ns.client.tid = setTimeout(lambda(playStopTimeout,ns),10000);   // if !commit then we want to restart lagging but playing stream, so stop first
            ns.play(false);
        }

        delete _model.streamsByName[name];

        if(!commit)
            _to_remove[name] = ns;
        else
            removeFromList(ns);
    }


    private function disposeNetStream(ns:NetStream):void{
     //   ns.client.tid && clearTimeout(ns.client.tid);
        ns.removeEventListener(AsyncErrorEvent.ASYNC_ERROR, streamErrorHandler);
        ns.removeEventListener(IOErrorEvent.IO_ERROR, streamErrorHandler);
        ns.removeEventListener(NetStatusEvent.NET_STATUS, streamPlayOnStatusHandler);
        ns.dispose();
    }


    private function removeFromList(ns:NetStream):void{
        const ind:int = _model.streamList.source.indexOf(ns);

        (ind > -1) && _model.streamList.removeItemAt(ind);
    }


    protected function removeAllStreams():void{

        for each(var ns:NetStream in _model.streamList)
            delete _model.streamsByName[(ns.client as NetStreamClient).data.name];


        _model.streamList.removeAll();
    }

    private function checkFailedStream(data:StreamData):void {

        debug("Stream failed; try again: "+data.name);

        removeStreamByName(data.name, false);
        _to_start.push(data);
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
