/**
 * User: palkan
 * Date: 5/28/13
 * Time: 2:42 PM
 */
package ru.teachbase.manage.rtmp {
import flash.events.ErrorEvent;
import flash.events.Event;
import flash.events.NetStatusEvent;
import flash.net.NetConnection;
import flash.net.Responder;

import mx.rpc.IResponder;

import ru.teachbase.constants.ErrorCodes;
import ru.teachbase.constants.NetConnectionStatusCodes;
import ru.teachbase.events.ErrorCodeEvent;
import ru.teachbase.manage.*;
import ru.teachbase.net.factory.ConnectionFactory;
import ru.teachbase.net.factory.FactoryErrorCodes;
import ru.teachbase.utils.extensions.FuncObject;
import ru.teachbase.utils.shortcuts.config;
import ru.teachbase.utils.shortcuts.debug;
import ru.teachbase.utils.shortcuts.error;

public class RTMPManager extends Manager {

    private var _connection:NetConnection;

    private var _factory:ConnectionFactory = new ConnectionFactory();

    private var _pinger:Pinger;

    private static const listeners:FuncObject = new FuncObject();

    public function RTMPManager(register:Boolean = false){
        super(register);
    }

    override protected function initialize(reinit:Boolean = false):void{

        var _url = config('net/rtmp');

        if(!_url){
            error("Missing RTMP options");
            _failed = true;
            return;
        }

        debug("[rtmp] init",arguments.callee);

        _pinger = new Pinger(this);

        _factory.ng.addEventListener(ErrorEvent.ERROR, connectionErrorHandler);
        _factory.ng.addEventListener(Event.COMPLETE, connectionCreatedHandler);
        _factory.createConnection(_url);
    }


    /**
     * @inherit
     */

    override public function clear():void{
        super.clear();
        _pinger && _pinger.stop();
        if(_connection){
            _connection.removeEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);
            _connection.close();
        }
        listeners.clear();
        _connection = null;
    }


    // --------- API (Begin) --------- //


    /**
     *  Register new RTMP listener
     *
     * @param type
     * @param handler
     */

    public static function listen(type:String, handler:Function):void{
        (handler is Function) && (listeners[type] = handler);
    }


    /**
     *
     * Unregister RTMP listener
     *
     * @param type
     * @param handler
     */


    public static function unlisten(type:String, handler:Function):void{
        listeners.deleteFromProperty(type,handler);
    }


    /**
     *
     * Make RTMP call
     * @param method    server method name
     * @param responder
     * @param rest    method arguments
     *
     */

    public function callServer(method:*, responder:IResponder, ...rest):void
    {
        rest.unshift(method, (responder ? new Responder(sendResult, sendError) : null));
        _connection && _connection.call.apply(null, rest);

        function sendResult(result:*):void
        {
            responder && responder.result(result);
        }

        function sendError(error:*):void
        {
            responder && responder.fault(error);
        }
    }



    tb_rtmp function incomingCall(name, ...args):void{
        (listeners[name] is Function) && listeners[name].apply(null,args);
    }



    public function __timeout(hard:Boolean = false){
        if(!hard)
            error('Timeout', ErrorCodes.PING_TIMEOUT);
        else
            error('Hard timeout', ErrorCodes.HARD_TIMEOUT);
    }


   // ---------- API (End) ---------- //


    protected function connectionErrorHandler(e:ErrorCodeEvent):void {
        _failed = true;
        switch(e.code){
            case FactoryErrorCodes.FAILED:
                error('Connection failed',ErrorCodes.CONNECTION_FAILED);
                break;
            case FactoryErrorCodes.TIMEOUT:
                error('Connection timeout',ErrorCodes.TIMEOUT);
                break;
            case FactoryErrorCodes.REJECTED:
                if(e.id & ErrorCodes.APPLICATION)
                    error('Application error', e.id);
                else
                    error(e.text, ErrorCodes.CONNECTION_FAILED);
                break;
        }
        removeFactoryListeners();
    }

    protected function connectionCreatedHandler(e:Event):void {
        _connection = _factory.connection;
        removeFactoryListeners();
        setupConnection();

        _initialized = true;
    }

    private function setupConnection():void{
        _connection.addEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);
        _connection.client = new RTMPClient(this);
        _pinger.start();
    }


    /**
     *  Active NetConnection
     */

    public function get connection():NetConnection {
        return _connection;
    }

    public function get connected():Boolean{
        return _connection && _connection.connected;
    }


    private function removeFactoryListeners():void{
        _factory.removeEventListener(ErrorEvent.ERROR, connectionErrorHandler);
        _factory.removeEventListener(Event.COMPLETE, connectionCreatedHandler);
    }

    protected function netStatusHandler(e:NetStatusEvent):void {

        debug("[rtmp data] NetStatus: "+e.info.code);

        switch(e.info.code){
            case NetConnectionStatusCodes.REJECTED:
                _initialized = false;
                if(e.info.errorId & ErrorCodes.APPLICATION)
                    error('Application error', uint(e.info.errorId));
                else
                    error(e.info.text, ErrorCodes.CONNECTION_FAILED);
                break;
            case NetConnectionStatusCodes.CLOSED:
                initialized && error('Connection dropped',ErrorCodes.CONNECTION_DROPPED);
                _initialized = false;
                break;
        }

    }
}

}

import flash.net.Responder;
import flash.utils.clearTimeout;
import flash.utils.setTimeout;

import ru.teachbase.manage.rtmp.RTMPManager;
import ru.teachbase.utils.shortcuts.$null;
import ru.teachbase.utils.shortcuts.config;
import ru.teachbase.utils.shortcuts.debug;
import ru.teachbase.utils.shortcuts.warning;


internal class Pinger{

    private var _rtmp:RTMPManager;
    private var _tid:uint;

    private var _ping_timeout:int;
    private var _wait_timeout:int;
    private var _wait_max:int;

    private var _latency:Number;

    private var _last_ts:Number;

    function Pinger(rtmp:RTMPManager){
        _wait_max = config('ping/wait_max',0);
        _wait_timeout = config('ping/wait');
        _ping_timeout = config('ping/interval');
        _rtmp = rtmp;
        start();
    }


    public function start(){
        if(!_rtmp.connection || !_rtmp.connection.connected) return;

        _tid = setTimeout(failed,_wait_timeout);

        _last_ts = (new Date()).getTime();

        (_rtmp.connection).call('ping', new Responder(success,$null));
    }


    private function success(...args){
        clearTimeout(_tid);
        _latency = (new Date()).getTime() - _last_ts;
        _latency > 1000 && warning('[rtmp] Latency is high: '+_latency);
        _tid = setTimeout(start,_ping_timeout);
    }

    private function failed(){

        // increase wait timeout after each fail

        _wait_timeout *= _wait_timeout;

        if(_wait_max && _wait_timeout > _wait_max)
            _rtmp.__timeout(true);
        else
            _rtmp.__timeout();
    }


    public function stop(){
        clearTimeout(_tid);
    }


}