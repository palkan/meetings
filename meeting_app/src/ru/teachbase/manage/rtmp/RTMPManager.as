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

        _factory.ng.addEventListener(ErrorEvent.ERROR, connectionErrorHandler);
        _factory.ng.addEventListener(Event.COMPLETE, connectionCreatedHandler);
        _factory.createConnection(_url);
    }


    /**
     * @inherit
     */

    override public function clear():void{
        super.clear();
        connected && _connection.close();
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
        _connection.call.apply(null, rest);

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

   // ---------- API (End) ---------- //


    protected function connectionErrorHandler(e:ErrorCodeEvent):void {
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
        _failed = true;
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
