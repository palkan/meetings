/**
 * User: palkan
 * Date: 8/14/13
 * Time: 5:33 PM
 */
package ru.teachbase.supervisors {
import flash.events.ErrorEvent;
import flash.utils.setTimeout;

import ru.teachbase.components.notifications.Notification;

import ru.teachbase.constants.PublishQuality;
import ru.teachbase.events.ChangeEvent;
import ru.teachbase.model.App;
import ru.teachbase.utils.CameraQuality;
import ru.teachbase.utils.CameraUtils;
import ru.teachbase.utils.shortcuts.config;
import ru.teachbase.utils.shortcuts.debug;
import ru.teachbase.utils.shortcuts.notify;
import ru.teachbase.utils.shortcuts.translate;

public class OutStreamSup extends Supervisor {

    /**
     * Tha amount of reserved bandwidth for other applications.
     */

    private const RESERVED_BW:Number = 100;

    private var _lastBW:Number = 0;

    private var _lastQuality:String;

    private var _wait_for_commit:Boolean = false;

    private static var instance:OutStreamSup;

    public function OutStreamSup() {
        super();


        if(App.rtmpMedia && App.rtmpMedia.stats)
            analyze(App.rtmpMedia.stats.bandwidth_up);
        else
            state = SupervisorState.MONITORING;

    }

    /**
     * Create supervisor instance and start to supervise.
     *
     * @param offset
     */


    public static function run(offset:Number = 0):void{

        instance && instance.sleep();

        instance = new OutStreamSup();

        if(offset){

            instance.sleep();

            setTimeout(instance.wake,offset);
        }

    }


    /**
     * Stop supervisor instance.
     */

    public static function stop():void{

        instance && instance.sleep();
        instance = null;

    }


    override public function monitor():void{

        if(!App.rtmpMedia || !App.rtmpMedia.stats) state = SupervisorState.MONITORING;

        addListeners();

        App.rtmpMedia.stats.checkBandwidthUp();
    }


    private function statsChanged(e:ChangeEvent):void{

        if(e.property == 'bandwidth_up'){
            removeListeners();
            analyze(e.value);
        }

    }

    private function statsError(e:ErrorEvent):void{
        removeListeners();
        state = SupervisorState.MONITORING;
    }


    private function analyze(value:Number):void{

        // zero bandwidth means that we've calculated with wrong data

        if(value === 0){
            state = SupervisorState.MONITORING;
            return;
        }

        debug('Analyze output bandwidth: '+value.toFixed(1)+' kB/s; previous: '+_lastBW+' kB/s; current: '+ App.rtmpMedia.stats.total_out+' kB/s');

        const quality:CameraQuality = CameraUtils.getMaxAvailableQuality(value - RESERVED_BW + App.rtmpMedia.stats.total_out);

        if(Math.abs( (value - _lastBW)/ value) > .3 || (!quality || quality.id != PublishQuality.HIGH)){

            debug("Commit output bandwidth: " + _wait_for_commit);

            if(_wait_for_commit){
                config('net/adaptive/out') && commit(quality);
                reset();
            }

            _wait_for_commit = !_wait_for_commit && (value < 1000 || _lastBW < 1000);

            state = SupervisorState.MONITORING;
        }else{
            _wait_for_commit = false;
            state = SupervisorState.NORMAL;
        }

        debug("Analyze output bandwidth: state "+state+"; camera quality "+(quality ? quality.id : "none"));

        _lastBW =  value;

    }


    private function commit(quality:CameraQuality):void{
        quality && (App.publisher.maxQuality = quality.id);

        if(!quality){
            App.publisher.cameraEnabled = false;
        }
        else if(!App.publisher.cameraEnabled){
            App.publisher.cameraEnabled = true;
            App.publisher.setQuality(quality.id);
        }
        else if(App.user.settings.publishquality > quality.id){
            _lastQuality = App.user.settings.publishquality;
            App.publisher.setQuality(quality.id);
            notify(new Notification(translate('bw_video_quality_decreased','notifications')),true);
        }
        else if(_lastQuality && App.user.settings.publishquality < quality.id && _lastQuality >= quality.id){
            App.publisher.setQuality(quality.id);
        }
    }


    private function addListeners():void{
        App.rtmpMedia.stats.addEventListener(ChangeEvent.CHANGED, statsChanged);
        App.rtmpMedia.stats.addEventListener(ErrorEvent.ERROR, statsError);
    }


    private function removeListeners():void{
        App.rtmpMedia.stats.removeEventListener(ChangeEvent.CHANGED, statsChanged);
        App.rtmpMedia.stats.removeEventListener(ErrorEvent.ERROR, statsError);
    }



}
}
