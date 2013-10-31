/**
 * User: palkan
 * Date: 10/17/13
 * Time: 3:35 PM
 */
package ru.teachbase.manage.rtmp {
import flash.events.ErrorEvent;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.IOErrorEvent;
import flash.events.SecurityErrorEvent;
import flash.events.TimerEvent;
import flash.net.URLLoader;
import flash.net.URLLoaderDataFormat;
import flash.net.URLRequest;
import flash.utils.ByteArray;
import flash.utils.Timer;
import flash.utils.clearTimeout;
import flash.utils.setTimeout;

import mx.core.EventPriority;
import mx.utils.ObjectUtil;
import mx.utils.ObjectUtil;

import ru.teachbase.components.notifications.Notification;

import ru.teachbase.constants.ErrorCodes;
import ru.teachbase.controller.RecordingController;
import ru.teachbase.events.ChangeEvent;
import ru.teachbase.events.GlobalEvent;
import ru.teachbase.manage.rtmp.PlayerStates;
import ru.teachbase.manage.rtmp.PlayerStates;
import ru.teachbase.manage.rtmp.PlayerStates;
import ru.teachbase.manage.rtmp.model.Packet;
import ru.teachbase.manage.streams.RecordStreamManager;
import ru.teachbase.manage.streams.StreamPlayer;
import ru.teachbase.model.App;
import ru.teachbase.model.TBSPacket;
import ru.teachbase.utils.TBSReader;
import ru.teachbase.utils.helpers.lambda;
import ru.teachbase.utils.shortcuts.debug;
import ru.teachbase.utils.shortcuts.error;
import ru.teachbase.utils.shortcuts.notify;
import ru.teachbase.utils.shortcuts.translate;
import ru.teachbase.utils.shortcuts.warning;

[Event(type="ru.teachbase.events.ChangeEvent",name="tb:changed")]
[Event(type="flash.events.ErrorEvent", name="error")]
[Event(type="flash.events.Event", name="complete")]

public class RecordingPlayer extends EventDispatcher{

    private const timer_fix_count:int = 10;

    private var _manager:RTMPPretender;

    private var _position:Number=0;
    private var _duration:Number=0;
    private var _bufferLength:Number=0;
    private var _backBufferLength:Number=0;

    private var _bufferTime:Number=0;
    private var _backBufferTime:Number=0;

    private var _backBufferLimit:Number=0;

    private var _initialized:Boolean = false;

    private var _state:String = PlayerStates.IDLE;

    private var _lastMessageIndex:Number = -1;


    private var _chunk_list:Object;
    private var _snapshot_list:Object;

    private var _last_chunk:int=-1;
    private var _chunks_to_load:Array = [];
    private var _chunks_to_load_position:int = 0;

    private var _snapshot:Object;

    private var _history_position:Number=0;

    private var _root_url:String;

    private var _stream_player:StreamPlayer;


    /**
     *
     * Timeshift delta for small intervals.
     *
     * If interval between messages less then 100ms invoke them together and add delta to next message.
     * Otherwise set delta to 0.
     *
     */

    private var _delta:Number = 0;

    private var _timer:Timer;
    private var _timer_interval:Number = 500;

    private var _tid:uint;
    private var _cid:uint;

    private var _allMessagesLoaded:Boolean = false;

    private var _loader:URLLoader;
    private var _loading_time:Number;

    private var _current_url:String;
    private var _load_complete:Function;
    private var _snaphot_loaded:Function;
    private var _chunks_loaded:Function;
    private var _state_before:String;
    private var _need_to_reset:Boolean = false;
    private var _state_reseted:Boolean = false;
    private var _need_to_reindex:Boolean = false;
    private var _wait_stream_buffer:Boolean = false;

    private var _ticks_count:int = 0;

    private var _last_ts:Number;

    private var _last_position:Number = 0;

    //---------- data ------------//

    private const messages:Vector.<TBSPacket> = new <TBSPacket>[];


    public function RecordingPlayer(mgr:RTMPPretender){

        _manager = mgr;


        _timer = new Timer(_timer_interval);


        _timer.addEventListener(TimerEvent.TIMER, updatePosition);

        _loader = new URLLoader();
        _loader.addEventListener(IOErrorEvent.IO_ERROR, loadFail);
        _loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, loadFail);
        _loader.addEventListener(Event.COMPLETE, loadComplete);

        _stream_player = new StreamPlayer(this,App.streams as RecordStreamManager);
        _stream_player.addEventListener(ChangeEvent.CHANGED, streamStateHandler);
    }

    public function init(root_url:String):void{

        _root_url = root_url;

        _loader.dataFormat = URLLoaderDataFormat.TEXT;

        loadData(_root_url+"index.json",configHandler);
    }


    public function togglePlay():void{
        if(_state === PlayerStates.PLAYING) pause();
        else
            play();
    }


    /**
     *
     */

    public function play():void{


        if(_state === PlayerStates.BUFFERING || _state === PlayerStates.SEEK){
            return;
        }

        if(_stream_player.state == PlayerStates.BUFFERING || _stream_player.state == PlayerStates.SEEK){
            _wait_stream_buffer = true;
            state = PlayerStates.BUFFERING;
            return;
        }

        state = PlayerStates.PLAYING;

        _stream_player.play();

        startTimer();

        prepareInvokeMessage();
    }

    /**
     *
     */

    public function pause():void{

        if(_state === PlayerStates.SEEK) return;

        state = PlayerStates.PAUSED;
        _stream_player.pause();
        stopTimer();

        _tid && clearTimeout(_tid);

    }


    /**
     *
     * @param time  Position in milliseconds
     */

    public function seek(time:Number):void{

        time = int(time/1000) * 1000;

        _state_before = _state;

        _state === PlayerStates.PLAYING && pause();

        state = PlayerStates.SEEK;

        _stream_player.seek(time/1000);

        seekLoop(time);
    }



    private function seekLoop(time:Number):void{

        var snap:Object;

        if(snap = needToLoadSnapshot(time)){
            _snaphot_loaded = lambda(seekLoop,time);
            _need_to_reset = true;

            debug("SEEK "+time+": load snapshot "+snap.ts);

            loadSnapshot(snap);
            return;

        }else
            _need_to_reset = _position > time;

        if(_need_to_reset){

            _need_to_reindex = true;

            debug("SEEK "+time+": reset state");

            GlobalEvent.addEventListener(GlobalEvent.RECONNECT,
                    function(e:GlobalEvent):void{

                        debug("SEEK "+time+": reset state complete");

                        GlobalEvent.removeEventListener(GlobalEvent.RECONNECT,arguments.callee);
                        _need_to_reset = false;
                        _position = time;
                        _state_reseted = true;
                        seekLoop(time);

                    },false,EventPriority.DEFAULT_HANDLER);

            (App.view.controller as RecordingController).reset();
            return;
        }

        needToLoadChunks(time);

        if(_chunks_to_load.length){

            debug("SEEK "+time+": load chunks "+_chunks_to_load.length);

            _chunks_loaded = lambda(seekLoop,time);
            loadChunk(_chunks_to_load[0]);
            return;
        }

        _need_to_reindex && updateMessagePosition();

        seekInBuffer(time);
    }


    public function seekInBuffer(time:Number):void{

        debug("SEEK "+time+": in buffer");

        while(messages.length > _lastMessageIndex+1 && messages[_lastMessageIndex+1].ts <= time){
            invokeNextMessage();
        }

        _position = time;

        completeSeek();
    }


    private function completeSeek():void{

        var _was_playing:Boolean = _state_before === PlayerStates.PLAYING;

        state = _stream_player.state == PlayerStates.BUFFERING ? PlayerStates.BUFFERING : _state_before;

        _stream_player.registerActiveStreams();

        _was_playing && play();

        dispatchEvent(new ChangeEvent(this,'position',_position));

    }


    public function getHistory(type:String):*{
        return _snapshot ? (ObjectUtil.isSimple(_snapshot[type]) ? _snapshot[type] : ObjectUtil.copy(_snapshot[type])) : null;
    }


    //---------------- private --------------//

    private function startTimer():void{

        _last_ts = (new Date()).time;
        _last_position = _position;
        _timer.start();
    }


    private function stopTimer():void{

        _timer.reset();
        actualizeTime();
    }


    private function actualizeTime():void{

        const ts:Number = (new Date()).time;

        const real_shift:Number = (ts - _last_ts);

        const calculated_shift:Number = _position - _last_position;

        if(Math.abs(real_shift - calculated_shift) > _timer_interval/2){
            _position = _last_position+real_shift;
            debug("time shift: "+(real_shift - calculated_shift));
        }

        _ticks_count = 0;
        _last_ts = ts;
        _last_position = _position;

    }

    private function needToLoadSnapshot(time:Number):Object{

        var i:int = _snapshot_list.length-1;

        for(;i>=0;i--){
            if(_snapshot_list[i].ts <= time) break;
        }

        return _snapshot_list[i].ts != _history_position ? _snapshot_list[i] : null;

    }


    private function needToLoadChunks(time:Number):void{
        if((_state_reseted && _backBufferTime > _history_position) || _history_position >= _bufferTime){
            _state_reseted = false;
            clearBuffer();
            _chunks_to_load =  findChunks(_history_position,time);
        }
    }



    private function clearBuffer():void{
        _bufferTime = _backBufferTime = _bufferLength = _backBufferLength = 0;

        messages.length = 0;

        _lastMessageIndex = -1;
    }


    private function findChunks(from:Number, to:Number):Array{

        var i:int = 0;

        const size:int = _chunk_list.length;

        var buf:Array = [];

        for(;i<size;i++){

            if(
                    (_chunk_list[i].ts <= from && (i<size-1) && _chunk_list[i+1].ts > from) ||
                            (_chunk_list[i].ts >= from && _chunk_list[i].ts <= to)
            )
                buf.push(i);
        }

        return buf;
    }


    private function updateMessagePosition():void{

        var i:int = 0;

        const size:int = messages.length;

        for(;i<size;i++){
            if(messages[i].ts > _history_position) break;
        }

        _lastMessageIndex = i-1;

        _need_to_reindex = false;
    }


    private function addMessages(list:Vector.<TBSPacket>):void{

        for each(var _p:TBSPacket in list) messages.push(_p);

        _bufferTime = messages[messages.length-1].ts;

        dispatchEvent(new ChangeEvent(this,'position',_position));

        if(_state === PlayerStates.BUFFERING) play();
    }

    protected function prepareInvokeMessage():void{

        _tid && clearTimeout(_tid);

        if(messages.length <= _lastMessageIndex+1){

            if(!_allMessagesLoaded){
                pause();
                state = PlayerStates.BUFFERING;
            }

            return;
        }

        const m:TBSPacket = messages[_lastMessageIndex+1];

        const delta:Number = m.ts - _position + _delta;

        if(delta < 100){
            _delta = delta;
            invokeNextMessage();
        }else{
            _delta = 0;
            _tid = setTimeout(invokeNextMessage,delta);
        }
    }


    protected function invokeNextMessage():void{

        if(messages.length <= _lastMessageIndex+1) return;

        const m:TBSPacket = messages[_lastMessageIndex+1];

        _lastMessageIndex++;

        const packet:Packet = ObjectUtil.copy(m.data) as Packet;

        debug("Send message: "+packet.type);

        _manager.tb_rtmp::incomingCall.apply(null, [packet.type,packet]);

        if(_backBufferLimit>0){
            _state === PlayerStates.PLAYING && cutMessages();
        }

        _state === PlayerStates.PLAYING && prepareInvokeMessage();
    }


    /**
     *
     * Remove old messages beyond the back buffer limit.
     *
     */

    private function cutMessages():void{

        const time:Number = _position - _backBufferLimit;

        while(messages.length && messages[0].ts < time){
            messages.shift();
            _lastMessageIndex--;
        }

        _backBufferTime = messages.length ? messages[0].ts : _position;
    }


    private function loadNextChunk():void{

        if(_chunk_list.length <= _last_chunk+1) _allMessagesLoaded = true;
        else{
            _last_chunk++;
            loadChunk(_last_chunk);
        }
    }


    private function loadChunk(index:int):void{

        var chunk:Object = _chunk_list[index];

        _loader.dataFormat = URLLoaderDataFormat.BINARY;

        loadData(_root_url+chunk.name,chunkHandler);
    }


    private function loadSnapshot(snap:Object):void{
        _loader.dataFormat = URLLoaderDataFormat.BINARY;
        loadData(_root_url+snap.name,snapshotHandler);
    }


    private function sendError(message:String = ""):void{
        dispatchEvent(new ErrorEvent(ErrorEvent.ERROR,false,false,message));
    }


    //------------------ loader methods/handlers ----------------//

    private function loadData(url:String,onComplete:Function = null):void {
        _current_url = url;
        _load_complete = onComplete;

        _loading_time = (new Date()).time;

        debug("Load data from "+url);

        _loader.load(new URLRequest(url));
    }

    private function loadComplete(e:Event):void{

        _loading_time = (new Date()).time - _loading_time;

        var parsedObj:*;

        if(_loader.dataFormat === URLLoaderDataFormat.TEXT){
            var loaded_json:String = String((e.target as URLLoader).data);
            parsedObj = JSON.parse(loaded_json);
        }else if(_loader.dataFormat === URLLoaderDataFormat.BINARY){
            parsedObj = (e.target as URLLoader).data as ByteArray;
        }else
            parsedObj = (e.target as URLLoader).data;

        _load_complete && _load_complete(parsedObj);
    }

    private function loadFail(e:ErrorEvent):void {
        warning("External file load failed: url " + _current_url, "Error: " + e.text);

        initialized && error("Failed to load file",ErrorCodes.FILE_LOAD_ERROR);
        !initialized && sendError();
    }


    //-------------- handlers ---------------//



    protected function streamStateHandler(e:ChangeEvent):void{

        if(e.property != 'state') return;

        debug("stream player state: "+ e.value);

        if(e.value == PlayerStates.BUFFERING){
            _state_before = (_state == PlayerStates.SEEK) ? _state_before : _state;
            pause();
            state = PlayerStates.BUFFERING;
            _wait_stream_buffer = true;
            return;
        }

        if(e.value == PlayerStates.BUFFER_FULL && _wait_stream_buffer){
            _wait_stream_buffer = false;

            state = PlayerStates.PAUSED;

            if(_state_before == PlayerStates.PLAYING) play();
        }

    }


    /**
     *
     * Setup recording from object.
     *
     * Objects contains: duration (in seconds), chunk list as array of objects (ts,name),
     * snapshots list (ts,name).
     *
     * @param data
     */

    protected function configHandler(data:Object):void{

        _duration = data.duration;

        _chunk_list = data.chunks;

        _snapshot_list = data.snapshots;

        debug("Config loaded: duration "+_duration+"; chunks "+_chunk_list.length+"; snapshots "+_snapshot_list.length+"; streams: "+data.streams.length);

        if(!_snapshot_list.length){
            error("History not found!");
            sendError();
            return;
        }

        // set back buffer limit to 15% of duration or 1 minute.

        _backBufferLimit = Math.max(60000,int(0.15*_duration));

        _stream_player.addEventListener(ErrorEvent.ERROR,streamErrorHandler);
        _stream_player.addEventListener(Event.COMPLETE,streamReadyHandler);
        _stream_player.buildMap(data.streams || []);

    }

    private function streamReadyHandler(e:Event):void{

        _loader.dataFormat = URLLoaderDataFormat.BINARY;

        loadData(_root_url+_snapshot_list[0].name,function(data:ByteArray){
            snapshotHandler(data);
            loadNextChunk();
        });

    }


    private function streamErrorHandler(e:ErrorEvent):void{
        error(e.text,ErrorCodes.HLS_STREAM_FAILED);
        !_initialized && sendError();
    }

    protected function snapshotHandler(data:ByteArray):void{

        const packet:TBSPacket = TBSReader.readPacket(data);

        if(!packet){
            error("Failed to decode snapshot packet",ErrorCodes.PACKET_DECODE_FAILED);
            !_initialized && sendError();
            return;
        }

        debug("Packet loaded: "+packet.ts+" ts");

        _history_position = packet.ts;

        _snapshot = packet.data;

        if(!_initialized)
        {
            _initialized = true;
            dispatchEvent(new Event(Event.COMPLETE));
        }

        _snaphot_loaded && _snaphot_loaded();
        _snaphot_loaded = null;

    }


    protected function chunkHandler(data:ByteArray):void{

        const list:Vector.<TBSPacket> = TBSReader.read(data);

        debug("Chunk loaded: "+list.length+" packets");

        addMessages(list);

        const timeout:Number = Math.max((_bufferTime - _position - _loading_time)/2,100);

        if(_chunk_list.length <= _last_chunk+1) _allMessagesLoaded = true;

        if(_chunks_to_load.length){

            if(_chunks_to_load_position+1 >= _chunks_to_load.length){

                _chunks_to_load.length = _chunks_to_load_position = 0;
                _chunks_loaded && _chunks_loaded();
                _chunks_loaded = null;
                _cid = setTimeout(loadNextChunk,timeout);

            }else{
                var next_index:int = _chunks_to_load[_chunks_to_load_position+1];
                loadChunk(next_index);
            }
        }else
            !_allMessagesLoaded && setTimeout(loadNextChunk,timeout);

    }


    protected function updatePosition(e:TimerEvent):void{
        _position+=_timer_interval;

        _ticks_count++;

        if(_ticks_count>timer_fix_count) actualizeTime();

        _bufferLength = Math.max(_bufferTime - _position,0);
        _backBufferLength = Math.max(_position - _backBufferTime,0);

        dispatchEvent(new ChangeEvent(this,'position',_position));



        if(_position >= _duration){
            pause();
            stopTimer();
            state = PlayerStates.COMPLETE;
        }

    }


    public function set state(value:String):void{
        var _old:String = _state;
        _state = value;

        if(_state == PlayerStates.BUFFERING){
           _state != _old && (App.view && App.view.lightbox && App.view.lightbox.show(null,false));
        }else if(_old == PlayerStates.BUFFERING){
            App.view && App.view.lightbox && App.view.lightbox.close();
        }

        dispatchEvent(new ChangeEvent(this,"state",_state,_old));
    }

    /**
     *
     * Buffer length in milliseconds.
     *
     * Determines the length (as time) of messages already loaded.
     *
     */

    public function get bufferTime():Number {
        return _bufferTime;
    }

    /**
     *
     * Duration in milliseconds
     *
     */

    public function get duration():Number {
        return _duration;
    }


    /**
     * Current position in milliseconds
     */

    public function get position():Number {
        return _position;
    }

    public function get state():String {
        return _state;
    }


    public function get initialized():Boolean {
        return _initialized;
    }

    public function get backBufferTime():Number {
        return _backBufferTime;
    }

    public function set backBufferTime(value:Number):void {
        _backBufferTime = value;
    }

    public function get backBufferLength():Number {
        return _backBufferLength;
    }

    public function get bufferLength():Number {
        return _bufferLength;
    }

    public function get backBufferLimit():Number {
        return _backBufferLimit;
    }

    public function set backBufferLimit(value:Number):void {
        _backBufferLimit = value;
    }

    public function get root_url():String {
        return _root_url;
    }
}
}
