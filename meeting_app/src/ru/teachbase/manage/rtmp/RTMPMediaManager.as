/**
 * User: palkan
 * Date: 8/15/13
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
import ru.teachbase.net.stats.NetworkStats;
import ru.teachbase.utils.extensions.FuncObject;
import ru.teachbase.utils.shortcuts.config;
import ru.teachbase.utils.shortcuts.debug;
import ru.teachbase.utils.shortcuts.error;

/**
 *
 * Creates and controls NetConnection for NetStreams only.
 *
 */

public class RTMPMediaManager extends Manager {

    private var _connection:NetConnection;

    private var _factory:ConnectionFactory = new ConnectionFactory();

    private var _stats:NetworkStats;

    public function RTMPMediaManager(register:Boolean = false){
        super(register);
    }

    override protected function initialize(reinit:Boolean = false):void{

        var _url = config('net/rtmp');

        if(!_url){
            error("Missing RTMP stream options");
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
        _connection = null;
    }


    // --------- API (Begin) --------- //



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
        if(!_stats) _stats = new NetworkStats();


        function statsInited(e:Event){
            _stats.removeEventListener(Event.COMPLETE, statsInited);
            _stats.removeEventListener(ErrorEvent.ERROR, statsFailed);
            _initialized = true;
        }

        function statsFailed(e:ErrorEvent){
            _stats.removeEventListener(ErrorEvent.ERROR, statsFailed);
            _stats.removeEventListener(Event.COMPLETE, statsInited);
            _failed = true;
        }

        _stats.addEventListener(Event.COMPLETE, statsInited);

        _stats.addEventListener(ErrorEvent.ERROR, statsFailed);

        _stats.initialize(_connection);
    }

    private function setupConnection():void{
        _connection.addEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);
        _connection.client = {};
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

        debug("[rtmp media] NetStatus: "+e.info.code);

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

    public function get stats():NetworkStats {
        return _stats;
    }
}
}
