package ru.teachbase.components.notifications {
import flash.display.DisplayObject;

import ru.teachbase.utils.shortcuts.translate;

public class Notification {
    private var _text:String;
    private var _icon:DisplayObject;

    private var _submitLabel:String;
    private var _submitFunction:Function;

    private var _cancelLabel:String;
    private var _cancelFunction:Function;

    public function Notification(text:String, icon:DisplayObject = null, submit_lb:String = '', submit_fun:Function = null, cancel_lb:String = '', cancel_fun:Function = null):void {
        _text = text;
        _icon = icon;

        _submitLabel = submit_lb ? submit_lb : translate('Confirm');
        _submitFunction = submit_fun;

        _cancelLabel = cancel_lb ? cancel_lb : translate('Cancel');
        _cancelFunction = cancel_fun;
    }


    public function get cancelLabel():String {
        return _cancelLabel;
    }

    public function get submitFunction():Function {
        return _submitFunction;
    }

    public function get cancelFunction():Function {
        return _cancelFunction;
    }

    public function get submitLabel():String {
        return _submitLabel;
    }

    public function get text():String {
        return _text;
    }

    public function get icon():DisplayObject {
        return _icon;
    }
}
}