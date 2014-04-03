/**
 * User: palkan
 * Date: 10/21/13
 * Time: 11:10 AM
 */
package ru.teachbase.manage.streams {

import flash.events.ErrorEvent;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.net.NetConnection;

import org.mangui.HLS.HLS;
import org.mangui.HLS.HLSEvent;
import org.mangui.HLS.HLSStates;

import ru.teachbase.events.ChangeEvent;
import ru.teachbase.manage.rtmp.PlayerStates;
import ru.teachbase.manage.rtmp.RecordingPlayer;
import ru.teachbase.manage.streams.model.CuePointData;
import ru.teachbase.manage.streams.model.NetStreamClient;
import ru.teachbase.manage.streams.model.StreamMap;
import ru.teachbase.manage.streams.model.StreamMapData;
import ru.teachbase.utils.shortcuts.debug;
import ru.teachbase.utils.shortcuts.error;
import ru.teachbase.utils.shortcuts.warning;

[Event(type="ru.teachbase.events.ChangeEvent",name="tb:changed")]
[Event(type="flash.events.Event", name="complete")]
[Event(type="flash.events.ErrorEvent", name="error")]

public class StreamPlayer extends EventDispatcher{

    private const connection:NetConnection = new NetConnection();

    private const hlsList:Vector.<HLS> = new <HLS>[];

    private var _activeHLS:Vector.<HLS> = new <HLS>[];

    private var _manager:RecordStreamManager;

    private var __state:String = PlayerStates.IDLE;

    private var _player:RecordingPlayer;

    private var _streams_map:StreamMap;

    private var _cuePoint:CuePointData;

    private var _bufferingCount:int = 0;

    private var _waitManifest:int = 0;

    private var __initialized:Boolean = false;


    public function StreamPlayer(player:RecordingPlayer, manager:RecordStreamManager=null){
        _player = player;
        _manager = manager;

        connection.connect(null);

        _player.addEventListener(ChangeEvent.CHANGED, playerStateChanged);
    }


    //------------------ API ---------------------//

    public function buildMap(list:Array):void{

        _streams_map = new StreamMap();

        if(!list.length){
            __state = PlayerStates.UNAVAILABLE;
            _initialized = true;
            return;
        }

        for each(var d:Object in list){
            var sdata:StreamMapData = new StreamMapData(d.start_ts, d.finish_ts);
            sdata.id = d.id;
            sdata.name = d.name;
            sdata.type = d.type;
            sdata.user_id = d.user_id;

            createHLSStream(sdata);

            _streams_map.add(sdata);
        }

    }


    public function play():void{

        if(_state == PlayerStates.BUFFERING || _state == PlayerStates.PLAYING || _state == PlayerStates.SEEK || _state == PlayerStates.UNAVAILABLE) return;

        for each(var h:HLS in _activeHLS) h.stream.resume();

        _state = PlayerStates.PLAYING;

    }

    public function pause(not_buferring:Boolean = false):void{

        if(_state == PlayerStates.UNAVAILABLE) return;

        for each(var h:HLS in _activeHLS) !(not_buferring && h.client.buffering) && h.stream.pause();
        _state = PlayerStates.PAUSED;
    }


    /**
     * Seek to position at <code>time</code> in seconds
     * @param time
     */

    public function seek(time:Number):void{

        if(_state == PlayerStates.UNAVAILABLE) return;

        stop();
        _state = PlayerStates.SEEK;

        _activeHLS.length = 0;

        const toActivate:Vector.<StreamMapData> = _streams_map.find(time*1000);

        for each(var data:StreamMapData in toActivate){
            data.hls.client.seekTime = time - data.start_ts/1000;
            data.hls.client.completed = false;
            _activeHLS.push(data.hls);
            data.hls.stream.seek(time - data.start_ts/1000);
        }

        if(!_activeHLS.length) _state = PlayerStates.BUFFER_FULL;

        _cuePoint = _streams_map.nextCuePoint(time*1000);
    }

    public function stop():void{

        if(_state == PlayerStates.UNAVAILABLE) return;

        for each(var h:HLS in _activeHLS) h.stream.close();
        _manager && _manager.removeHLSStreams();
        _state = PlayerStates.IDLE;
    }


    public function registerActiveStreams():void{

        for each(var h:HLS in _activeHLS) _manager && _manager.addHLSStream(h.stream);

    }


    public function createHLSStream(stream:StreamMapData):void{

        if(_state == PlayerStates.UNAVAILABLE) return;

       // ns.client.onMetaData({hasVideo:true,hasAudio:true});

        var _hls:HLS = new HLS();
        _hls.stream.client = new NetStreamClient(stream);
        _hls.stream.client.hls = _hls;

        _hls.addEventListener(HLSEvent.PLAYBACK_COMPLETE,_completeHandler);
        _hls.addEventListener(HLSEvent.ERROR,_errorHandler);
        _hls.addEventListener(HLSEvent.FRAGMENT_LOADED,_fragmentHandler);
        _hls.addEventListener(HLSEvent.MANIFEST_LOADED,_manifestHandler);
        _hls.addEventListener(HLSEvent.MEDIA_TIME,_mediaTimeHandler);
        _hls.addEventListener(HLSEvent.STATE,_stateHandler);
        _hls.addEventListener(HLSEvent.QUALITY_SWITCH,_switchHandler);

        _hls.client.manifestLoaded = false;

        stream.hls = _hls;

        hlsList.push(_hls);

        _hls.load(_player.root_url+stream.name+"/"+stream.name+".m3u8");
    }


    //----------------------------------------------------------------//


    protected function handleCuePoint(cue:CuePointData):void{

        if(cue.kind == CuePointData.STOP){

            cue.data.hls.stream.close();

            _manager && _manager.removeHLSStream(cue.data.hls);

            const ind:int = _activeHLS.indexOf(cue.data.hls);

            ind > -1 && _activeHLS.splice(ind,1);

        }else{

            if(cue.data.hls.position != 0) cue.data.hls.stream.seek(0);
            else cue.data.hls.stream.resume();

            _activeHLS.push(cue.data.hls);

            _manager && _manager.addHLSStream(cue.data.hls.stream);

        }

    }


    private function _completeHandler(e:HLSEvent):void{
        debug("complete");
        const hls:HLS = e.target as HLS;
        hls.client.completed = true;

        _manager && _manager.removeHLSStream(hls);

        const ind:int = _activeHLS.indexOf(hls);

        ind > -1 && _activeHLS.splice(ind,1);
    }


    private function _errorHandler(e:HLSEvent):void{
        error("HLS error: "+e.message);
        dispatchEvent(new ErrorEvent(ErrorEvent.ERROR,false,false, e.message));
    }

    private function _fragmentHandler(e:HLSEvent):void{
        debug("fragment");
    }

    private function _manifestHandler(e:HLSEvent):void{
        const hls:HLS = e.target as HLS;

        hls.client.manifestLoaded = true;

        _waitManifest++;

        if(_waitManifest == _streams_map.size){
            _initialized = true;
        }
    }

    private function _mediaTimeHandler(e:HLSEvent):void{

        ((e.target as HLS).stream.client.position is Function) && (e.target as HLS).stream.client.position(e.mediatime.position);

    }

    private function _stateHandler(e:HLSEvent):void {

        debug(e.state);

        const hls:HLS = e.target as HLS;

        if(!hls.client.completed && e.state == HLSStates.PLAYING_BUFFERING){
            hls.client.buffering = true;
            _bufferingCount++;

            pause(true);
            _state = PlayerStates.BUFFERING;
        }

        if(e.state == HLSStates.IDLE){
            warning('stream stopped');
            if(hls.client.buffering){
                hls.client.buffering = false;
                _bufferingCount--;
                !_bufferingCount && (_state = PlayerStates.BUFFER_FULL);
            }
        }

        if(hls.client.buffering && (e.state == HLSStates.PLAYING)){
            debug("seek and position: "+hls.client.seekTime+" - "+hls.position);
            hls.client.buffering = false;
            _bufferingCount--;
            hls.stream.pause();
            !_bufferingCount && (_state = PlayerStates.BUFFER_FULL);
        }


        if(e.state == HLSStates.PAUSED_BUFFERING){
            _state = PlayerStates.PAUSED;
        }

    }

    private function _switchHandler(e:HLSEvent):void{}


    protected function playerStateChanged(e:ChangeEvent):void{

        if(e.property != "position" || !_cuePoint) return;

        if(int(e.value) >= _cuePoint.ts){

            handleCuePoint(_cuePoint);

            _cuePoint = _streams_map.nextCuePoint(_cuePoint.ts+1);
        }

    }

    private function get _initialized():Boolean{
        return __initialized;
    }

    private function set _initialized(value:Boolean):void{
        if(__initialized == value || !value) return;

        __initialized = value;
        seek(0);
        registerActiveStreams();
        dispatchEvent(new Event(Event.COMPLETE));
    }

    public function get initialized():Boolean {
        return __initialized;
    }

    public function get state():String{
        return __state;
    }

    protected function get _state():String {
        return __state;
    }

    protected function set _state(value:String):void {

        if(__state == value) return;

        var _old:String = __state;
        __state = value;

        dispatchEvent(new ChangeEvent(this,'state',__state,_old));
    }
}
}
