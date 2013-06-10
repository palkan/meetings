package ru.teachbase.events {
import flash.events.Event;

public class GlobalEvent extends Event {
    public static const USER_LEAVE:String = "tb:global_user_leave";
    public static const USER_ADD:String = "tb:global_user_add";

    public static const MODULE_REMOVE:String = "tb:global_module_remove";
    public static const MODULE_ADD:String = "tb:global_module_add";

    public static const MEETING_SETTINGS_UPDATE:String = "tb:global_settings_update";
    public static const MEETING_STATE_UPDATE:String = "tb:global_state_update";

    public static const PERMISSIONS_UPDATE:String = "tb:permissions";
    public static const START_PRIVATE_CHAT:String = "start_private_chat";

    private var _value:*;

    /**
     *
     * @param type
     * @param value
     * @param bubbles
     * @param cancelable
     */
    public function GlobalEvent(type:String, value:* = null, bubbles:Boolean = false, cancelable:Boolean = false) {
        super(type, bubbles, cancelable);
        _value = value;
    }

    /**
     *
     * @param type
     * @param listener
     * @param useCapture
     * @param priority
     * @param useWeakReference
     */

    public static function addEventListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false):void {

        GlobalEventDispatcher.tb_events::instance.addEventListener(type, listener, useCapture, priority, useWeakReference);

    }

    /**
     *
     * @param type
     * @param listener
     * @param useCapture
     */

    public static function removeEventListener(type:String, listener:Function, useCapture:Boolean = false):void {

        GlobalEventDispatcher.tb_events::instance.removeEventListener(type, listener, useCapture);

    }

    /**
     *
     * @param type
     * @param value
     */

    public static function dispatch(type:String, value:* = null):void {

        GlobalEventDispatcher.tb_events::instance.dispatchEvent(new GlobalEvent(type, value));

    }

    public function get value():* {
        return _value;
    }


}
}