/**
 * User: palkan
 * Date: 8/9/13
 * Time: 12:34 PM
 */
package ru.teachbase.net.stats {
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.net.NetStream;
import flash.net.NetStreamInfo;
import flash.utils.clearInterval;
import flash.utils.setInterval;

import ru.teachbase.manage.streams.model.NetStreamClient;
import ru.teachbase.utils.Arrays;
import ru.teachbase.utils.data.LimitArray;
import ru.teachbase.utils.shortcuts.debug;

/**
 *  Dispatches when metrics is updated.
 *
 *  @eventType flash.events.Event.CHANGE
 */

[Event(type="flash.events.Event", name="change")]

/**
 * Dispatches when stream send/receive no bytes for a long time (3s)
 *
 * @eventType flash.events.Event.CLEAR
 */

[Event(type="flash.events.Event", name="clear")]

/**
 *  Class for supervising NetStream properties.
 */

public class RTMPWatch extends EventDispatcher{

    /**
     * Determine how often continuous values are recalculated. Now: every 10 seconds (60 / 6).
     *
     * So, there will be 6 values to determine average drop rate.
     */

    private const HISTORY_INTERVAL:uint = 6;

    private const RESTART_THRESHOLD:uint = 3000;

    private var _netstream:NetStream;
    private var _client:NetStreamClient;



    private var _updateID:uint;
    private var _updateDelay:int;

    private var _counter:int;
    private var _values:LimitArray;

    private var _lastFramesDropped:int = 0;

    //-------- observable fields --------//

    private var _framesDropped:Number = 0;

    private var _framesDroppedPerMinute:Number = 0;

    private var _audioBytesCount:Number = 0;

    private var _audio_kbs:Number = 0;

    private var _videoBytesCount:Number = 0;

    private var _video_kbs:Number = 0;

    private var _total_kbs:Number = 0;

    private var _max_kbs:Number = 0;

    private var _avg_kbs:Number = 0;

    private var _fps:Number = 0;

    private var _empty_since:Number = 0;


    /**
     *
     * @param target
     */


    function RTMPWatch(target:NetStream = null) {

        _netstream = target;
        _client = target.client as NetStreamClient;

    }


    public function watch(delay:Number = 1000):void{

        if(!_netstream) return;

        _updateDelay = delay;

        _counter = 60 / HISTORY_INTERVAL;

        _values = new LimitArray(_counter);

        _lastFramesDropped = (_netstream.info as NetStreamInfo).droppedFrames;

        _updateID = setInterval(updateProps,delay);

    }


    public function unwatch():void{

        _updateID && clearInterval(_updateID);

    }


    protected function updateProps():void{

        if(!_netstream || isNaN(_netstream.time)) return;

        const info:NetStreamInfo = _netstream.info as NetStreamInfo;

        _framesDropped = info.droppedFrames;

        _audioBytesCount = info.audioByteCount;
        _audio_kbs = info.audioBytesPerSecond / (1024 / 8);

        _videoBytesCount = info.videoByteCount;
        _video_kbs = info.videoBytesPerSecond / (1024 / 8);

        _total_kbs = _audio_kbs + _video_kbs;

        _max_kbs = Math.max(total_kbs,_max_kbs);

        if(!_counter){

            _values.add({
               "dropFrames":info.droppedFrames - _lastFramesDropped,
               "kbs": total_kbs,
                "fps": _netstream.currentFPS
            });

            _lastFramesDropped = info.droppedFrames;

            _counter = 60 /HISTORY_INTERVAL;

            _framesDroppedPerMinute = Arrays.sum(Arrays.key('dropFrames',_values));

            _avg_kbs = Arrays.average(Arrays.key('kbs',_values));

            _fps = Arrays.average(Arrays.key('fps',_values));

        }else
            _counter--;


        if(!_total_kbs){

            if(!_empty_since) _empty_since = (new Date()).time;
            else{

                if((new Date()).time - _empty_since > RESTART_THRESHOLD){

                    debug("RTMPWatch: stream was empty for more than 3 seconds; "+_client.data.name);

                    dispatchEvent(new Event(Event.CLEAR));
                }

            }

        }else if(_empty_since) _empty_since = 0;


        dispatchEvent(new Event(Event.CHANGE));

    }

    /**
     *
     * Current incoming audio speed in kB/s
     *
     */

    public function get audio_kbs():Number {
        return _audio_kbs;
    }


    /**
     *
     * Current incoming video speed in kB/s
     *
     */


    public function get video_kbs():Number {
        return _video_kbs;
    }

    /**
     *
     * Current frames per second.
     *
     * This is more significant value for metrics. Decreasing means insufficient bandwidth or system resources
     *
     *
     *
     */


    public function get fps():Number {
        return _fps;
    }

    /**
     *
     * Peak speed in kb/s.
     *
     */

    public function get max_kbs():Number {
        return _max_kbs;
    }


    /**
     *
     * Total audio bytes received
     *
     */


    public function get audioBytesCount():Number {
        return _audioBytesCount;
    }


    /**
     *
     * Total video bytes received
     *
     */

    public function get videoBytesCount():Number {
        return _videoBytesCount;
    }


    /**
     *
     * Total frames dropped
     *
     */


    public function get framesDropped():Number {
        return _framesDropped;
    }


    /**
     *
     * Return the number of frames dropped in the last minute
     *
     */


    public function get framesDroppedPerMinute():Number {
        return _framesDroppedPerMinute;
    }


    /**
     *
     * Average speed kb/s.
     *
     */

    public function get avg_kbs():Number {
        return _avg_kbs;
    }

    public function get total_kbs():Number {
        return _total_kbs;
    }

    public function get client():NetStreamClient {
        return _client;
    }
}

}