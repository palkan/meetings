package ru.teachbase.manage {
import flash.events.ErrorEvent;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.ProgressEvent;

import ru.teachbase.error.SingletonError;
import ru.teachbase.utils.shortcuts.debug;

[Event(name="complete", type="flash.events.Event")]
[Event(name="progress", type="flash.events.ProgressEvent")]
[Event(name="error", type="flash.events.ErrorEvent")]

/**
 * @author Teachbase (created: Jun 25, 2012)
 */
public final class Initializer extends EventDispatcher {
    public static const instance:Initializer = new Initializer();

    /**
     * [index] = Manager instance or Manager SubClass
     */
    private static const managersToDo:Array = new Array();

    private static var _complete:Boolean;

    private var _reinitializeMode:Boolean = false;

    private var _total:int;

    //------------ constructor ------------//

    public function Initializer() {
        if (instance)
            throw new SingletonError();
    }

    //------------ initialize ------------//

    /**
     *
     * @param managers classes for init
     *
     */
    public static function initializeManagers(...managers):void {
        instance._reinitializeMode = false;
        instance.initializeSequence(managers);
    }

    /**
     *
     * @param managers
     */

    public static function reinitializeManagers(...managers):void{
        instance._reinitializeMode = true;
        instance.initializeSequence(managers);
    }

    /**
     *
     */


    public function clear():void{
        managersToDo.length = 0;
        Shared.DISPATCHER.removeEventListener(ManagerEvent.INITIALIZED, managerInited);
        Shared.DISPATCHER.removeEventListener(ManagerEvent.ERROR, managerFailed);
    }


    private function initializeSequence(managers:Array):void {
        Shared.DISPATCHER.addEventListener(ManagerEvent.INITIALIZED, managerInited);
        Shared.DISPATCHER.addEventListener(ManagerEvent.ERROR, managerFailed);

        managersToDo.push.apply(null, managers);

        _total = managers.length;

        // start init:
        initilizeNext();
    }

    private function initilizeNext():void {
        if (managersToDo && managersToDo.length) {
            var manager:Manager = managersToDo[0] as Manager;
            dispatchEvent(new ProgressEvent(ProgressEvent.PROGRESS, false, false, _total - managersToDo.length, _total));
            managersToDo[0].preinitialize(_reinitializeMode);
        }else{
            _complete = true;
            Shared.DISPATCHER.removeEventListener(ManagerEvent.INITIALIZED, managerInited);
            Shared.DISPATCHER.removeEventListener(ManagerEvent.ERROR, managerFailed);
            dispatchEvent(new Event(Event.COMPLETE));
        }
    }

    //--------------- ctrl ---------------//

    //------------ get / set -------------//

    public function get complete():Boolean {
        _reinitializeMode = false;
        return _complete;
    }

    //------- handlers / callbacks -------//

    private function managerInited(e:ManagerEvent):void {
        const index:int = managersToDo.indexOf(e.manager);
        if (index !== -1)
            managersToDo.splice(index, 1);

        debug('manager initialized:', e.manager.toString());

        if (!managersToDo.length) {
            _complete = true;
            Shared.DISPATCHER.removeEventListener(ManagerEvent.INITIALIZED, managerInited);
            Shared.DISPATCHER.removeEventListener(ManagerEvent.ERROR, managerFailed);
            dispatchEvent(new Event(Event.COMPLETE));
        }
        else {
            initilizeNext();
        }
    }

    private function managerFailed(e:ManagerEvent):void {
        Shared.DISPATCHER.removeEventListener(ManagerEvent.INITIALIZED, managerInited);
        Shared.DISPATCHER.removeEventListener(ManagerEvent.ERROR, managerFailed);
        _reinitializeMode = false;
        dispatchEvent(new ErrorEvent(ErrorEvent.ERROR, false, false, "Manager failed: " + e.manager.toString()));
    }

}
}


import flash.events.EventDispatcher;
import flash.utils.Dictionary;

import ru.teachbase.manage.Manager;

internal class Shared extends Manager {
    public static function get DISPATCHER():EventDispatcher {
        return dispatcher;
    }

    public static function get MANAGERS():Vector.<Manager> {
        return managers;
    }

    public static function get MANAGERS_BY_CLASS():Dictionary {
        return managersByClass;
    }
}

