/**
 * User: palkan
 * Date: 5/28/13
 * Time: 12:01 PM
 */
package ru.teachbase.events {
import flash.events.ErrorEvent;

public class ErrorCodeEvent extends ErrorEvent {

    private var _code:uint;
    private var _id:uint;

    public function ErrorCodeEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false, text:String = "", code:uint = 0, errorId:uint = 0) {
        super(type, bubbles, cancelable, text);
        _code = code;
        _id = errorId;
    }

    public function get code():uint {
        return _code;
    }

    public function get id():uint {
        return _id;
    }
}
}
