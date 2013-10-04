package ru.teachbase.manage {
import flash.events.EventDispatcher;
import flash.utils.Dictionary;
import flash.utils.getQualifiedClassName;

import ru.teachbase.events.ChangeEvent;
import ru.teachbase.manage.ManagerEvent;

/**
 * Base class for all core-managers.
 * @author Teachbase (created: Jun 25, 2012)
 */

[Event(type="ru.teachbase.manage.ManagerEvent", name="")]

public class Manager {
    /**
     * Cross-manager EventDispatcher
     */
    public static const dispatcher:EventDispatcher = new EventDispatcher();

    /**
     * Fully initialized managers
     */
    protected static const managers:Vector.<Manager> = new Vector.<Manager>();

    /**
     * Fully initialized managers : <code>Dictionary.&lt;Class&gt;[Manager]</code>
     */
    protected static const managersByClass:Dictionary = new Dictionary(true);

    /**
     * All managers.
     */
    protected static const managersCollection:Vector.<Manager> = new Vector.<Manager>();

    private const shortName:String = getQualifiedClassName(this).replace(/.*::/, '');

    protected const dependencies:Array = new Array();

    private var __initialized:Boolean = false;
    private var __waitDependencies:Boolean = false;
    private var __failed:Boolean = false;
    protected var __registered:Boolean = false;

    protected var _disposed:Boolean = false;

    //------------ constructor ------------//

    /**
     *
     * @param registered    define whether to add instance to managersByClass dict
     * @param dependenciesClasses
     *
     */

    public function Manager(registered:Boolean = false, dependenciesClasses:Array = null) {
        __registered = registered;
        managersCollection.push(this);
        dependenciesClasses && dependencies.push.apply(null, dependenciesClasses);
    }

    //------------ initialize ------------//

    public final function preinitialize(reinit:Boolean = false):void {
        removeInitializedDependencies();

        // only one time - first time:
        if (dependencies.length && !_waitDependencies) {
            // test, wait, continue:
            _waitDependencies = true;
            dispatcher.addEventListener(ManagerEvent.INITIALIZED, oneDependencyInitializedHandler);
            return;
        }

        // else immediately:
        if (!dependencies.length) {
            initialize(reinit);
            _waitDependencies && dispatcher.removeEventListener(ManagerEvent.INITIALIZED, oneDependencyInitializedHandler);
            _waitDependencies = false;
        }
    }

    /**
     *
     * @param reinit  Define whether we want to reinitialize manager (after clear)
     */

    protected function initialize(reinit:Boolean = false):void {
        // template method
    }


    /**
     * Clear manager data. Set <i>initialized</i> to false.
     *
     * Almost equal to <i>dispose</i> but we do not want to free the manager.
     */


    public function clear():void{
        _initialized = false;
        _failed = false;
    }


    private function removeInitializedDependencies():void {
        for (var i:int; i < dependencies.length; ++i) {
            var Clss:Class = dependencies[0];
            for each(var man:Manager in managers) {
                if (man is Clss && man.initialized) {
                    dependencies.splice(i, 1);
                    i--;
                }
            }
        }
    }

    //--------------- ctrl ---------------//

    /**
     *
     * @param Clazz Manager class
     * @param mustBeRegistered   Define whether we have to find registered Manager; otherwise we are looking for the first Manager of a given class.
     * @return
     */

    public static function getManagerInstance(Clazz:Class, mustBeRegistered:Boolean = true):Manager {
        if (!(managersByClass[Clazz] is Manager)) {
            const collection:Vector.<Manager> = mustBeRegistered ? managers : managersCollection;
            for each(var m:Manager in collection) {
                if (m is Clazz)
                    return !mustBeRegistered ? m : (managersByClass[Clazz] = m);
            }
        }
        return managersByClass[Clazz];
    }

    public function toString():String {
        return shortName + (dependencies.length ? ' ( ' + dependencies + ' ) ' : '');
    }

    //------------ get / set -------------//

    public function get initialized():Boolean {
        return __initialized;
    }

    protected function set _initialized(value:Boolean):void {
        if (__initialized == value)
            return;

        // add manager to registered list (we need to check that it is not already in list 'cause it can be reinitialized)

        value && __registered && (managers.indexOf(this) < 0) && managers.push(this);
        __initialized = value;
        value && dispatcher.dispatchEvent(new ManagerEvent(ManagerEvent.INITIALIZED, this));
    }

    //------- handlers / callbacks -------//

    private function oneDependencyInitializedHandler(e:ChangeEvent):void {
        removeInitializedDependencies();
        preinitialize();
    }

    public static function disposeManagers():void {
        for each (var manager:Manager in managersCollection) {
            manager.dispose();
        }

        managersCollection.length = 0;
        managers.length = 0;
        for (var key:Object in managersByClass) delete managersByClass[key];
    }

    public function dispose():void {
        clear();
        _disposed = true;
    }


    public function get _waitDependencies():Boolean {
        return __waitDependencies;
    }

    public function set _waitDependencies(value:Boolean):void {
        if (__waitDependencies == value) return;

        __waitDependencies = value;

        dispatcher.dispatchEvent(new ManagerEvent(ManagerEvent.WAIT_DEPS, this));
    }

    public function get _failed():Boolean {
        return __failed;
    }

    public function set _failed(value:Boolean):void {
        if (__failed == value) return;

        __failed = value;

        value && dispatcher.dispatchEvent(new ManagerEvent(ManagerEvent.ERROR, this)) && (managersCollection.splice(managersCollection.indexOf(this), 1));


    }
}
}