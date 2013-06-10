/**
 * User: palkan
 * Date: 5/24/13
 * Time: 7:36 PM
 */
package ru.teachbase.utils.logger {
import flash.events.Event;

public class LoggerEvent extends Event {

    public static const LOG:String = "tb:log";

    private var _level:String;
    private var _message:String;

    public function LoggerEvent(level:String, message:String,bubbles:Boolean = false, cancelable:Boolean = false) {

        super(LOG,bubbles,cancelable);
        _level = level;
        _message = message;

    }

    override public function clone():Event{

        return new LoggerEvent(_level,_message,bubbles,cancelable);
    }

    public function get level():String {
        return _level;
    }

    public function get message():String {
        return _message;
    }
}
}
