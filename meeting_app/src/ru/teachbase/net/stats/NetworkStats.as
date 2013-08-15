/**
 * User: palkan
 * Date: 8/12/13
 * Time: 1:04 PM
 */
package ru.teachbase.net.stats {
import flash.events.ErrorEvent;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.net.NetConnection;
import flash.net.Responder;
import flash.utils.clearInterval;
import flash.utils.clearTimeout;
import flash.utils.setInterval;
import flash.utils.setTimeout;

import ru.teachbase.events.ChangeEvent;
import ru.teachbase.manage.rtmp.RTMPManager;
import ru.teachbase.utils.Arrays;
import ru.teachbase.utils.helpers.dummyBytes;
import ru.teachbase.utils.helpers.lambda;
import ru.teachbase.utils.helpers.toArray;
import ru.teachbase.utils.shortcuts.debug;
import ru.teachbase.utils.shortcuts.warning;

/**
 *
 * Collects rtmp network statistics.
 *
 */

[Event(type = "ru.teachbase.events.ChangeEvent", name = "tb:changed")]
[Event(type = "flash.events.Event", name="complete")]

public class NetworkStats extends EventDispatcher{

    private const LATENCY_UPDATE_INTERVAL:int = 20000;

    private const UPDATE_INTERVAL:int = 2000;

    private const BW_CHECK_TIMEOUT:int = 10000;

    private var _connection:NetConnection;

    private var _output:RTMPWatch;

    private var _input:Vector.<RTMPWatch>;

    private var _protocol:String;

    private var _updateID:uint;

    private var _bwCheckID:uint;

    private var _latency:Number = 0;

    private var _total_out:Number = 0;

    private var _total_in:Number = 0;

    private var _bandwidth_up:Number = 0;

    private var _bandwidth_down:Number = 0;


    public function NetworkStats() {

        _input = new <RTMPWatch>[];

    }

    /**
     *
     * Initialize network stats and run all checkers.
     *
     * @param conn
     */


    public function initialize(conn:NetConnection):void{

        connection = conn;

        collectBandwidthStatistics();

        setInterval(checkLatency,LATENCY_UPDATE_INTERVAL);
    }


    /**
     *
     * @param watcher
     */

    public function registerInput(watcher:RTMPWatch):void{

        _input.push(watcher);

    }

    /**
     *
     * @param watcher
     */

    public function registerOutput(watcher:RTMPWatch):void{

        _output = watcher;

    }


    /**
     *
     * @param watcher
     */

    public function unregisterInput(watcher:RTMPWatch):void{

        if(_input.indexOf(watcher) > -1) _input.splice(_input.indexOf(watcher),1);

        if(!_input.length) _total_in = 0;

    }


    /**
     *  Collect data from watchers and updates total values.
     *
     *  Starts output watcher; input watchers are always running.
     *
     */

    public function startCollect():void{

        _updateID = setInterval(updateTotals,UPDATE_INTERVAL);

        _output && _output.watch();

    }


    /**
     *
     * Stop collect data from watchers.
     *
     * Stop output watcher.
     *
     */

    public function stopCollect():void{

        _updateID && clearInterval(_updateID);

        _output && _output.unwatch();

    }


    /**
     *
     */

    public function unregisterOutput():void{
        _output = null;
        _total_out = 0;
    }


    /**
     * Send 'ping' packet and wait for reply; calculates latency.
     *
     */

    public function checkLatency():void{

        if(!_connection || !_connection.connected) return;

        const start:Number = (new Date()).getTime();

        _connection.call('ping', new Responder(success,failure));

        function success(...args):void{

            const finish:Number = (new Date()).getTime();

            _latency = finish - start;

            dispatchEvent(new ChangeEvent(this,'latency',_latency));

        }


        function failure(...args):void{
            warning("ping call failed", args);
            sendError('ping call failed');
        }

    }

    /**
     *
     * Initiate bandwidth checking (server->client).
     *
     */

    public function checkBandwidth():void{

        _bwCheckID = setTimeout(lambda(sendError,'bw check timeout'),BW_CHECK_TIMEOUT);

        _connection.call('checkBandwidth',null);
    }

    /**
     *
     * Check upstream bandwidth (client->server).
     *
     * @param e
     */

    public function checkBandwidthUp():void{

        const start:Number = (new Date()).getTime();

        _connection && _connection.connected && _connection.call('ping', new Responder(success, failure), dummyBytes(32 * 1024));


        function success(...args):void {

            const time:Number = ((new Date()).getTime() - start - latency);

            _bandwidth_up =  time > 0 ? ((32 * 8) / (time / 1000)) : 0;

            dispatchEvent(new ChangeEvent(this,'bandwidth_up',_bandwidth_up));

        }


        function failure(...args):void{
            warning('bandwidth up checking failed');
            sendError('bandwidth up checking failed');
        }

    }

    /**
     *
     * Callback for bandwidth checking.
     *
     * @param args
     * @return
     */

    public function onBWCheck(...args):int{
        args.length && _connection.call('checkBandwidth', null, args[0]);
        return 0;
    }

    /**
     *
     * Callback for bandwidth data from server.
     *
     * @param data
     */

    public function onBWDone(data:Object):void{

        debug(data);

        _bwCheckID && clearTimeout(_bwCheckID);

        const time:Number = data['time'];
        const bytes:Number = data['bytes'];

        _bandwidth_down = (((bytes * 8) / 1024) / (time / 1000));

        dispatchEvent(new ChangeEvent(this,'bandwidth_down',_bandwidth_down));
    }


    protected function updateTotals():void{

        _output && (_total_out = _output.total_kbs);

        _total_in = Arrays.sum(Arrays.key('total_kbs',toArray(_input)));

        dispatchEvent(new ChangeEvent(this,'totals',null));

    }


    protected function collectBandwidthStatistics():void{
        runCheckers([
                {property:'latency',checker:checkLatency},
                {property:'bandwidth_down',checker:checkBandwidth},
                {property:'bandwidth_up',checker:checkBandwidthUp}
            ]
        );
    }


    protected function runCheckers(arr:Array):void{

        if(!arr || !arr.length){
            dispatchEvent(new Event(Event.COMPLETE));
            return;
        }

        const checker_obj:Object = arr.shift();

        addEventListener(ChangeEvent.CHANGED, propertyWaiter(checker_obj.property,arr));
        checker_obj.checker();

    }


    protected function propertyWaiter(property:String, rest:Array):Function{

        return  function(e:ChangeEvent){
            if(e.property != property) return;
            removeEventListener(ChangeEvent.CHANGED, arguments.callee);
            runCheckers(rest);
        }

    }


    protected function sendError(message:String):void{
        dispatchEvent(new ErrorEvent(ErrorEvent.ERROR,false,false,message));
    }

    public function get output():RTMPWatch{
        return _output;
    }

    public function get input():Vector.<RTMPWatch> {
        return _input;
    }

    public function get total_out():Number {
        return _total_out;
    }

    public function get total_in():Number {
        return _total_in;
    }

    public function get connection():NetConnection {
        return _connection;
    }

    public function set connection(value:NetConnection):void {
        _connection = value;

        if(value){
            RTMPManager.listen('onBWCheck',onBWCheck);
            RTMPManager.listen('onBWDone',onBWDone);
        }else{
            RTMPManager.unlisten('onBWCheck',onBWCheck);
            RTMPManager.unlisten('onBWDone',onBWDone);
        }
    }

    public function get latency():Number {
        return _latency;
    }

    public function get bandwidth_up():Number {
        return _bandwidth_up;
    }

    public function get bandwidth_down():Number {
        return _bandwidth_down;
    }

    public function get protocol():String {
        return _connection && _connection.connected ? _connection.protocol : '';
    }
}
}
