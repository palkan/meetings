/**
 * User: palkan
 * Date: 8/14/13
 * Time: 11:24 AM
 */
package ru.teachbase.supervisors {
import flash.errors.IllegalOperationError;
import flash.utils.clearTimeout;
import flash.utils.setTimeout;

public class Supervisor {

    public static const NORMAL_INTERVALS:Array = [2*60000,3*60000,4*60000,5*60000];
    public static const MONITORING_INTERVALS:Array = [10000, 25000, 45000, 60000];

    private var _timeoutID:uint;

    private var _state:String = SupervisorState.NORMAL;

    private var _position:int = -1;

    public function Supervisor(){

    }

    /**
     *
     * Run monitoring function
     *
     */


    public function monitor():void{

        throw new IllegalOperationError('Method must be overriden!');

    }


    public function sleep():void{

        _timeoutID && clearTimeout(_timeoutID);

        state = SupervisorState.SLEEP;

    }

    public function wake():void{

        state = SupervisorState.NORMAL;

    }


    protected function reset():void{
        _position = -1;
    }


    private function loop():void{

        switch(_state){

            case SupervisorState.MONITORING:
                _position = _position < MONITORING_INTERVALS.length - 1 ? _position+1 : MONITORING_INTERVALS.length - 1;
                _timeoutID = setTimeout(monitor, MONITORING_INTERVALS[_position]);
                break;
            case SupervisorState.NORMAL:
                _position = _position < NORMAL_INTERVALS.length - 1 ? _position+1 : NORMAL_INTERVALS.length - 1;
                _timeoutID = setTimeout(monitor, NORMAL_INTERVALS[_position]);
                break;
        }

    }

    protected function get state():String{ return _state;}

    protected function set state(value:String):void{

        if(_state != value) _position = -1;

        _state = value;

        loop();

    }

}
}
