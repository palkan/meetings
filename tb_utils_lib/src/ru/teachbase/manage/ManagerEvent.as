/**
 * User: palkan
 * Date: 5/28/13
 * Time: 10:47 AM
 */
package ru.teachbase.manage {
import flash.events.Event;

public class ManagerEvent extends Event {

    public static const INITIALIZED:String = "tb:manager:init";
    public static const WAIT_DEPS:String = "tb:manager:wait";
    public static const ERROR:String = "tb:manager:error";

    private var _manager:Manager;

    public function ManagerEvent(type:String, manager:Manager, bubbles:Boolean = false, cancelable:Boolean = false) {
        super(type, bubbles, cancelable);
        _manager = manager;
    }


    public function get manager():Manager {
        return _manager;
    }
}
}
