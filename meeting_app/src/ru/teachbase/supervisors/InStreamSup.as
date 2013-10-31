/**
 * User: palkan
 * Date: 8/14/13
 * Time: 5:33 PM
 */
package ru.teachbase.supervisors {
import flash.events.ErrorEvent;
import flash.utils.setTimeout;

import ru.teachbase.events.ChangeEvent;
import ru.teachbase.model.App;
import ru.teachbase.utils.shortcuts.config;
import ru.teachbase.utils.shortcuts.debug;

public class InStreamSup extends Supervisor {

    /**
     * Tha amount of reserved bandwidth for other applications.
     */

    private const RESERVED_BW:Number = 100;

    private var _lastBW:Number = 0;

    private var _wait_for_commit:Boolean = false;

    private static var instance:InStreamSup;

    public function InStreamSup() {
        super();


        if(App.rtmpMedia && App.rtmpMedia.stats)
            analyze(App.rtmpMedia.stats.bandwidth_down);
        else
            state = SupervisorState.MONITORING;

    }

    /**
     * Create supervisor instance and start to supervise.
     *
     * @param offset specifies delay in starting monitoring.
     *
     */


    public static function run(offset:Number = 0):void{

        instance && instance.sleep();

        instance = new InStreamSup();

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

        App.rtmpMedia.stats.checkBandwidth();
    }


    private function statsChanged(e:ChangeEvent):void{

        if(e.property == 'bandwidth_down'){
            removeListeners();
            analyze(e.value);
        }

    }

    private function statsError(e:ErrorEvent):void{
        removeListeners();
        state = SupervisorState.MONITORING;
    }


    private function analyze(value:Number):void{

        debug('Analyze input bandwidth: '+value.toFixed(1)+' kB/s; previous '+_lastBW+' kB/s; current ' + App.rtmpMedia.stats.total_in + ' kB/s');

        const size:int = App.meeting.streamList.source.length;

        if(_wait_for_commit || Math.abs((value - _lastBW)/ value) > .3){

            debug("Commit input bandwidth: " + _wait_for_commit);

            if(_wait_for_commit){
                config('net/adaptive/in',false) && commit(value);
                reset();
            }

            _wait_for_commit = !_wait_for_commit && (value < size*700 || _lastBW < size*700);

            state = SupervisorState.MONITORING;
        }else{
            _wait_for_commit = false;
            state = SupervisorState.NORMAL;
        }

        _lastBW =  value;

    }


    protected function commit(value:Number):void{
        App.streams && App.streams.setupBandwidth(value - RESERVED_BW + App.rtmpMedia.stats.total_in);
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
