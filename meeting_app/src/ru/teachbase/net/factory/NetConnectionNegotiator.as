package ru.teachbase.net.factory {


import flash.errors.IOError;
import flash.events.AsyncErrorEvent;
import flash.events.ErrorEvent;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.NetStatusEvent;
import flash.events.SecurityErrorEvent;
import flash.events.TimerEvent;
import flash.net.NetConnection;
import flash.utils.Timer;

import ru.teachbase.events.ErrorCodeEvent;
import ru.teachbase.constants.NetConnectionStatusCodes;
import ru.teachbase.utils.shortcuts.debug;
import ru.teachbase.utils.shortcuts.error;

[Event(name="complete", type="flash.events.Event")]

[Event(name="error", type="ru.teachbase.events.ErrorCodeEvent")]

internal class NetConnectionNegotiator extends EventDispatcher {

    private static const DEFAULT_TIMEOUT:Number = 180000;
    private static const CONNECTION_ATTEMPT_INTERVAL:Number = 30000;

    private var _host:String;
    private var _path:String;

    private var _pnp:Array;
    private var _timeOutTimer:Timer;
    private var _connectionTimer:Timer;
    private var _failedConnectionCount:int;
    private var _attemptIndex:int;

    private var _nc:NetConnection;

    private var _netConnections:Vector.<NetConnection> = new Vector.<NetConnection>();


    public function NetConnectionNegotiator():void {
        super();
    }


    public function createNetConnection(host:String, path:String, portsAndProtocols:String):void {
        _host = host;
        _path = path;

        _pnp = new Array();

        for each(var str:String in portsAndProtocols.split(","))
            _pnp.push(str.split(":"));


        initializeConnectionAttempts();
        tryToConnect(null);
    }


    private function initializeConnectionAttempts():void {
        // Master timeout
        _timeOutTimer = new Timer(DEFAULT_TIMEOUT, 1);
        _timeOutTimer.addEventListener(TimerEvent.TIMER_COMPLETE, masterTimeout);
        _timeOutTimer.start();

        // Individual attempt sequencer
        _connectionTimer = new Timer(CONNECTION_ATTEMPT_INTERVAL);
        _connectionTimer.addEventListener(TimerEvent.TIMER_COMPLETE, tryToConnect);

        // Initialize counters
        _failedConnectionCount = 0;
        _attemptIndex = 0;
    }


    private function tryToConnect(e:TimerEvent):void {

        _connectionTimer.reset();
        _connectionTimer.start();

        _nc = new NetConnection();
        _nc.addEventListener(NetStatusEvent.NET_STATUS, onNetStatus, false, 0, true);
        _nc.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onNetSecurityError, false, 0, true);
        _nc.addEventListener(AsyncErrorEvent.ASYNC_ERROR, onAsyncError, false, 0, true);
        _netConnections.push(_nc);
        try {

            debug("Connect to: "+_pnp[_attemptIndex][0] + "://" + _host + ":" + _pnp[_attemptIndex][1] + "/" + _path, _nc);
            _nc.connect(_pnp[_attemptIndex][0] + "://" + _host + ":" + _pnp[_attemptIndex][1] + "/" + _path);

            _attemptIndex++;

            // if this is last attempt we wanna wait 'till the end)

            if (_attemptIndex >= _pnp.length) {
                _connectionTimer.stop();
            }
        }
        catch (ioError:IOError) {
            handleFailed("IOError: Unable to connect through " + _pnp[_attemptIndex - 1][0] + ":" + _pnp[_attemptIndex - 1][1]);
        }
        catch (argumentError:ArgumentError) {
            handleFailed("ArgumentError: Unable to connect through " + _pnp[_attemptIndex - 1][0] + ":" + _pnp[_attemptIndex - 1][1]);
        }
        catch (securityError:SecurityError) {
            handleFailed("SecurityError: Unable to connect through " + _pnp[_attemptIndex - 1][0] + ":" + _pnp[_attemptIndex - 1][1]);
        }
    }


    private function onNetStatus(e:NetStatusEvent):void {
        if (e.target != _nc) return;

        switch (e.info.code) {
            case NetConnectionStatusCodes.REJECTED:
            {
                clear();
                dispatchEvent(new ErrorCodeEvent(ErrorEvent.ERROR, false, false, e.info.text, FactoryErrorCodes.REJECTED, uint(e.info.errorId)));
                break;
            }
            case NetConnectionStatusCodes.FAILED:
            case NetConnectionStatusCodes.CLOSED:
                handleFailed();
                break;
            case NetConnectionStatusCodes.SUCCESS:
                debug("Connected", _nc);
                shutDownUnsuccessfulConnections();
                removeNCListeners(_nc);
                dispatchEvent(new Event(Event.COMPLETE));
                break;
        }
    }


    private function shutDownUnsuccessfulConnections():void {
        _timeOutTimer.stop();
        _connectionTimer.stop();
        for (var i:int = 0; i < _netConnections.length; i++) {
            var nc:NetConnection = _netConnections[i];
            nc.removeEventListener(NetStatusEvent.NET_STATUS, onNetStatus);
            nc.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onNetSecurityError);
            nc.removeEventListener(AsyncErrorEvent.ASYNC_ERROR, onAsyncError);
            if (!nc.connected) {
                nc.close();
                delete _netConnections[i];
            }
        }
    }

    private function handleFailed(message:String = ''):void {

        _failedConnectionCount++;
        if (_failedConnectionCount >= _pnp.length) {
            clear();
            dispatchEvent(new ErrorCodeEvent(ErrorEvent.ERROR, false, false, message, FactoryErrorCodes.FAILED));
        } else {
            _nc && removeNCListeners(_nc) && _nc.close();
            tryToConnect(null);
        }
    }

    private function onNetSecurityError(e:SecurityErrorEvent):void {
        handleFailed("SecurityErrorEvent:  " + e.target);
    }


    private function onAsyncError(e:AsyncErrorEvent):void {
        handleFailed("AsyncErrorEvent:  " + e.target);
    }


    private function masterTimeout(e:TimerEvent):void {
        clear();
        dispatchEvent(new ErrorCodeEvent(ErrorEvent.ERROR, false, false, 'Timed out', FactoryErrorCodes.TIMEOUT));
    }

    private function removeNCListeners(nc:NetConnection):Boolean {
        nc.removeEventListener(NetStatusEvent.NET_STATUS, onNetStatus, false);
        nc.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onNetSecurityError, false);
        nc.removeEventListener(AsyncErrorEvent.ASYNC_ERROR, onAsyncError, false);
        return true;
    }

    public function clear() {
        _connectionTimer && _connectionTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, tryToConnect), _connectionTimer.reset();
        _timeOutTimer && _timeOutTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, masterTimeout), _timeOutTimer.reset();
        _nc && removeNCListeners(_nc) && (_nc = null);
    }

    public function get nc():NetConnection {
        return _nc;
    }
}
}

