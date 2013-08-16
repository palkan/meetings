package ru.teachbase.components.settings {

import flash.display.DisplayObject;

import mx.core.INavigatorContent;

import spark.components.Group;

public class SettingsElement extends Group implements INavigatorContent {


    protected var _initialized:Boolean = false;
    protected var _disposed:Boolean = true;


    public function SettingsElement() {
        super();
    }

    public function dispose():void{}

    public function get label():String {
        return null;
    }

    public function get icon():Class {
        return null;
    }

    public function get iconOver():DisplayObject{
        return null;
    }

    public function get iconOut():DisplayObject
    {
        return null;
    }

    public function get creationPolicy():String {
        return null;
    }

    public function set creationPolicy(value:String):void {
    }

    public function createDeferredContent():void {
    }

    public function get deferredContentCreated():Boolean {
        return false;
    }
}
}