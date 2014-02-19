package ru.teachbase.manage.livecursor {
import caurina.transitions.Tweener;

import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.geom.ColorTransform;
import flash.geom.Point;
import flash.text.AntiAliasType;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.utils.clearTimeout;
import flash.utils.setTimeout;

import ru.teachbase.model.App;
import ru.teachbase.utils.shortcuts.style;

/**
 * @author palkan 19.02.2014
 */
internal final class LiveCursor extends Sprite {

    private const HIDE_TIMEOUT:Number = 2000;

    private const position:Point = new Point(NaN, NaN);

    private var _showLabel:Boolean;
    private var _label:String;
    private var _field:TextField;

    private var _id:Number;

    private var _icon:DisplayObject;

    private var _tid:uint;

    private var _color:uint;

    private var _active:Boolean = false;

    //------------ constructor ------------//

    public function LiveCursor(id:Number, color:uint = 0) {
        super();

        _id = id;


        _icon = style("wb", "pointerBig");

        _color = color;

        if(color){
            const ctr:ColorTransform = new ColorTransform();
            ctr.color = color;

            _icon.transform.colorTransform = ctr;
        }
        //_icon.filters = [new DropShadowFilter(3, 45, 0, .4, 3, 3), new GlowFilter(0x00A2FF,1,10,10,2,1,true)];
        addChild(_icon);


        field.text = App.meeting.usersByID[_id] ? App.meeting.usersByID[_id].fullName : "";

        this.alpha = 0;
    }

    //------------ initialize ------------//

    private function createField():TextField {
        _field = new TextField();
        _field.multiline = false;
        _field.selectable = false;
        _field.mouseEnabled = false;
        _field.autoSize = TextFieldAutoSize.LEFT;
        _field.antiAliasType = AntiAliasType.ADVANCED;

        _field.background = true;
        _field.backgroundColor = 0xFFCCFF;

        _field.border = true;
        _field.borderColor = 0x0;

        _field.x = 10;

        return _field;
    }

    //--------------- ctrl ---------------//

    public function colorize(color:uint):void{
        if(color != _color){
            const ctr:ColorTransform = new ColorTransform();
            ctr.color = color;

            _icon.transform.colorTransform = ctr;
        }
    }

    public function move(x:int, y:int, anchor:Boolean = false):void {

        activate(!anchor);

        if (isNaN(position.x) && isNaN(position.y)) {
            this.x = x;
            this.y = y;
        }
        else
            Tweener.addTween(this, {x: x, y: y, time:.5});

        position.x = x;
        position.y = y;
    }

    public function activate(hide:Boolean = true):void {

        _tid && clearTimeout(_tid);

        if(!_active){
            Tweener.addTween(this, {alpha: 1, time: .2});
            _active = true;
        }

        hide && (_tid = setTimeout(deactivate,HIDE_TIMEOUT));
    }

    public function deactivate():void {
        Tweener.addTween(this, {alpha: 0, time: .2});
        _active = false;
        _tid = null;
    }


    public function dispose():void{
        _tid && clearTimeout(_tid);
    }

    private function addLabel():void {
        if (!contains(field))
            field.alpha = 0;

        addChild(field);
        Tweener.addTween(field, {alpha: 1, time: .2});
    }

    private function remLabel():void {
        contains(field) && removeChild(field);
        Tweener.addTween(field, {alpha: 0, time: .2});
    }

    //------------ get / set -------------//

    public function get showLabel():Boolean {
        return _showLabel;
    }

    public function set showLabel(value:Boolean):void {
        if (_showLabel === value)
            return;

        _showLabel = value;

        value ? addLabel() : remLabel();
    }

    public function get label():String {
        return _label || _id.toString();
    }

    public function set label(value:String):void {
        if (_label === value)
            return;

        _label = value;
    }

    public function get field():TextField {
        return _field || createField();
    }

    public function get id():int {
        return _id;
    }

    public function get color():uint {
        return _color;
    }
}
}