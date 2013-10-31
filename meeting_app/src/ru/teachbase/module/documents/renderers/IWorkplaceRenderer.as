package ru.teachbase.module.documents.renderers {
import mx.core.IVisualElement;
import mx.core.IVisualElementContainer;

import ru.teachbase.module.documents.model.FileItem;

import ru.teachbase.utils.interfaces.IDisposable;

import spark.components.Group;

public interface IWorkplaceRenderer extends IDisposable,IVisualElement {

    /**
     * Has external controls or not
     */

    function get hasControls():Boolean;

    /**
     *
     * Attach whiteboard or not
     *
     */

    function get useWB():Boolean;

    /**
     * Renderer width/height ratio
     */

    function get ratio():Number;

    /**
     * Renderer initial width
     */

    function get initialWidth():Number;

    /**
     *
     */

    function get editable():Boolean;


    function set editable(value:Boolean):void;


    function set data(value:Object):void;

    /**
     * Additional data information
     */

    function get data():Object;

    function set file(value:FileItem):void;

    /**
     *
     */

    function get file():FileItem;

    /**
     *
     * @param w
     * @param h
     */

    function resize(w:Number, h:Number):void;

    /**
     *
     * Zoom in (true) or out (false)
     *
     * @param flag
     */

    function zoom(flag:Boolean):void;

    /**
     *
     * Rotate CW (true) or CCW (false)
     *
     * @param flag
     */

    function rotate(flag:Boolean):void;

    /**
     *
     * Add controls to renderer
     *
     * @param container
     * @return
     */

    function initControls(container:IVisualElementContainer):Boolean;

    /**
     *
     * @param container
     * @return
     */

    function initParent(container:Group):Boolean;

}
}
