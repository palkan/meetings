/**
 * User: palkan
 * Date: 5/21/13
 * Time: 6:44 PM
 */
package ru.teachbase.utils {
import flash.events.EventDispatcher;
import flash.events.IEventDispatcher;
import flash.events.TimerEvent;
import flash.utils.Timer;

import ru.teachbase.events.ChangeEvent;

import ru.teachbase.utils.interfaces.IDisposable;

/**
 *
 * Observer watches target's property and dispatch ChangeEvent when it is changed.
 *
 * Work with simple typed properties (namely, Number or String)
 *
 */


[Event(type="ru.teachbase.events.ChangeEvent",name="tb:changed")]

public class Observer extends EventDispatcher implements  IDisposable{

    public const NUMBER:String = "num";
    public const STRING:String = "string";


    private var _observable:Object;
    private var _field:String;
    private var _type:String;

    private var _oldValue:* = '';
    private var _newValue:* = '';

    private var _timer:Timer;

    private var _freq:int = 5000;
    private var _disposed:Boolean = false;

    private var _delta:Number =  1 >> 2;


    /**
     *
     * Create new Observer
     *
     * @param target Observed object
     * @param field  Observed property
     * @param type
     */


    public function Observer(target:Object, field:String, type:String = NUMBER) {

        _observable = target;
        _field = field;
        _type = type;

    }


    public function observe():void{

        !_timer && (_timer = new Timer(_freq));

        if(_timer.running) return;

        _timer.addEventListener(TimerEvent.TIMER, tick);

        _timer.start();

    }

    public function unobserve():void{

        if(!_timer || !_timer.running) return;

        _timer.removeEventListener(TimerEvent.TIMER, tick);

        _timer.stop();

    }


    public function dispose():void{

        _timer.running && _timer.stop();

        _timer = null;

    }


    protected function tick(e:TimerEvent):void{

        if(!_observable) dispose();

        if(this[_type+"_cmp"]()) dispatchEvent(new ChangeEvent(_observable,_field,_newValue,_oldValue));
    }



    protected function num_cmp():Boolean{

        if(Math.abs(_observable[_field] - _newValue)>_delta){

            _oldValue = _newValue;
            _newValue = _observable[_field];

            return true;
        }

        return false;
    }


    protected function string_cmp():Boolean{

        if(_observable[_field] !== _newValue){

            _oldValue = _newValue;
            _newValue = _observable[_field];

            return true;
        }

        return false;
    }

    /**
     *
     * Frequency of property checking (in ms)
     *
     */


    public function get freq():int {
        return _freq;
    }

    public function set freq(value:int):void {
        _freq = value;

        _timer && _timer.running && (_timer.delay = _freq);
    }


    public function get disposed():Boolean {
        return _disposed;
    }

    /**
     *
     * Precision for Number comparison
     *
     */

    public function get delta():Number {
        return _delta;
    }

    public function set delta(value:Number):void {
        _delta = value;
    }
}
}
