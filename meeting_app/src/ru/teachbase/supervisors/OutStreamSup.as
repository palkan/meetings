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
import ru.teachbase.utils.shortcuts.debug;
import ru.teachbase.utils.shortcuts.notify;
import ru.teachbase.utils.shortcuts.translate;

public class OutStreamSup extends Supervisor {

    /**
     * Tha amount of reserved bandwidth for other applications.
     */

    private const RESERVED_BW:Number = 100;

    private var _lastBW:Number = 0;

    private static var instance:OutStreamSup;

    public function OutStreamSup() {
        super();


        if(App.rtmp && App.rtmp.stats)
            analyze(App.rtmp.stats.bandwidth_up);
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

        if(!App.rtmp || !App.rtmp.stats) state = SupervisorState.MONITORING;

        addListeners();

        App.rtmp.stats.checkBandwidthUp();
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

        debug('Analyze output bandwidth: '+value.toFixed(1)+' kB/s');

        const quality:CameraQuality = CameraUtils.getMaxAvailableQuality(value - RESERVED_BW);

        App.publisher.maxQuality = quality.id;

        if(!quality){
            App.publisher.setQuality(PublishQuality.NO_CAM);
            notify(new Notification(translate('bw_cam_not_allowed','notifications')),true);
        }
        else if(App.user.settings.publishQuality > quality.id){
            App.publisher.setQuality(quality.id);
            notify(new Notification(translate('bw_video_quality_decreased','notifications')),true);
        }


        if(Math.abs( (value - _lastBW)/ value) > .3 && (!quality || quality.id != PublishQuality.HIGH))
            state = SupervisorState.MONITORING;
        else
            state = SupervisorState.NORMAL;

        _lastBW =  value;

    }


    private function addListeners():void{
        App.rtmp.stats.addEventListener(ChangeEvent.CHANGED, statsChanged);
        App.rtmp.stats.addEventListener(ErrorEvent.ERROR, statsError);
    }


    private function removeListeners():void{
        App.rtmp.stats.removeEventListener(ChangeEvent.CHANGED, statsChanged);
        App.rtmp.stats.removeEventListener(ErrorEvent.ERROR, statsError);
    }



}
}
