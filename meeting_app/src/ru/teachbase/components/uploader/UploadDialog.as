/**
 * User: palkan
 * Date: 9/30/13
 * Time: 2:41 PM
 */
package ru.teachbase.components.uploader {


import mx.core.INavigatorContent;

import ru.teachbase.module.documents.model.DocumentData;

import spark.components.Group;

public class UploadDialog extends Group implements INavigatorContent {

    protected var _initialized:Boolean = false;
    protected var _disposed:Boolean = true;

    protected var _item:DocumentData;

    private var _selected:Boolean = false;

    public function UploadDialog() {
    }

    public function dispose():void{}

    public function submit():void{ selected = false;}

    public function cancel():void{ selected = false;}

    [Bindable]
    public function get selected():Boolean{ return _selected;}
    public function set selected(value:Boolean):void{ _selected = value;}

    public function get label():String {
        return null;
    }

    public function get icon():Class{
        return null;
    }

    public function get item():DocumentData{
        return _item;
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
