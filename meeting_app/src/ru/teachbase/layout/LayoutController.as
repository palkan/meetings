package ru.teachbase.layout {
import flash.display.DisplayObjectContainer;
import flash.events.EventDispatcher;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.utils.clearTimeout;
import flash.utils.setTimeout;

import mx.events.FlexEvent;

import ru.teachbase.behaviours.dragdrop.DragDirection;
import ru.teachbase.layout.model.ILayoutResizer;
import ru.teachbase.layout.model.ITreeLayoutElement;
import ru.teachbase.layout.model.LayoutElementData;
import ru.teachbase.layout.model.LayoutModel;
import ru.teachbase.layout.model.ResizerModel;
import ru.teachbase.manage.layout.events.LayoutEvent;
import ru.teachbase.manage.layout.model.LayoutChangeData;
import ru.teachbase.tb_internal;
import ru.teachbase.utils.LayoutUtils;
import ru.teachbase.utils.data.Stack;
import ru.teachbase.utils.data.TreeNode;

/**
 * @author Webils (2012)
 */


[Event(type="ru.teachbase.manage.layout.events.LayoutEvent", name="tb:layout_change")]
[Event(type="ru.teachbase.manage.layout.events.LayoutEvent", name="tb:layout_lock")]
[Event(type="ru.teachbase.manage.layout.events.LayoutEvent", name="tb:layout_active")]

public class LayoutController extends EventDispatcher {

    protected const bordersDelta:int = 25;

    protected var _model:LayoutModel;
    protected var _container:DisplayObjectContainer;
    protected var _gap:int = 4;
    protected var _initialized:Boolean = false;

    protected var _prevModel:LayoutModel;

    protected var _width:int = 0;
    protected var _height:int = 0;


    protected const minHeight:int = 150;
    protected const minWidth:int = 170;


    protected const contMinWidth:int = 800;
    protected const contMinHeight:int = 557;


    protected var _minW:int = 100;
    protected var _minH:int = 120;


    /**
     * When model is not active, updateDisplayList() is blocked.
     */

    protected var _active:Boolean = false;

    protected var _expanded:Boolean = false;

    protected var _expandedTarget:ITreeLayoutElement;

    private var _locked:Boolean = true;

    public var maxId:int = 0;


    //-------- Resizers ---------//

    /**
     * Object containing all ResizerModel objects
     */

    private var _resizers:Object;

    private var _resizersFun:Function;

    private var _availableResizers:Vector.<ILayoutResizer> = new <ILayoutResizer>[];

    private var _resizersInUse:Vector.<ILayoutResizer> = new <ILayoutResizer>[];

    private var _resizersID:uint;

    private var _waitForRes:int = 0;

    public function LayoutController() {
    }


    /**
     *
     *  Create model (tree) from data elements.
     *
     *
     */

    public function preinit(elements:Array = null):void {

        _model = new LayoutModel();

        _resizers = {};

        if (elements && elements.length > 0)
            _model.from_arr(elements);
        else
            _model.init(null);
    }


    /**
     *
     * initializes preinited element and adds it to the container
     *
     *
     */

    public function initElement(element:ITreeLayoutElement):Boolean {

        if (_model.elements[element.elementId] == undefined) {
            _model.elements[element.elementId] = element;
            maxId = (maxId < element.elementId) ? element.elementId : maxId;
            return true;
        }

        return false;

    }


    /**
     *
     * Assigns container to the controller
     */

    public function init(container:DisplayObjectContainer):void {
        _initialized = true;
        _active = true;
        _container = container;
    }

    /**
     * Rollback to previous state.
     *
     * Use when you want to cancel last commited change (e.g. when you cancel drag'n'drop).
     */

    public function rollback():void{

        if(!_prevModel) return;

        _model = _prevModel;
        _prevModel = null;

        updateDisplayList();
    }


    /**
     * Define Resizer generator function.
     *
     * fun() -> ILayoutResizer
     *
     * @param fun
     * @see ru.teachbase.layout.model.ILayoutResizer
     */


    public function useResizers(fun:Function):void{
        _resizersFun = fun;
        updateDisplayList();
    }

    /**
     *
     * @param groupKey
     * @param l
     * @param width
     * @param height
     * @param x
     * @param y
     * @param rw
     * @param rh
     */

    protected function initResizer(groupKey:String, l:uint, width:int, height:int, x:int, y:int, rw:int, rh:int):void {

        var r:ResizerModel;
        r = new ResizerModel(groupKey);
        _resizers[groupKey] = r;
        r.dragBounds = new Rectangle();
        r.direction = l;
        r.gap = 2 * _gap;
        r.param = (l === 0) ? height : width;
        r.groupParam = (l === 1) ? height : width;
        r.position = new Point(x, y);

        var _y:int = y;
        var _x:int = x;
        var _w:int = width;
        var _h:int = height;

        if (l === 1) {
            _w = 0;
            _y = (height - rh > _minH) ? y - (height - rh) + _minH : y;
            _h = (rh > _minH) ? (rh - _minH) + (y - _y) : (y - _y);
        } else {
            _h = 0;
            _x = (width - rw > _minW) ? x - (width - rw) + _minW : x;
            _w = (rw > _minW) ? (rw - _minW) + (x - _x) : (x - _x);
        }

        r.dragBounds.setTo(_x, _y, _w, _h);
    }

    /**
     *
     */


    protected function hideResizers():void{
        const size:int = _resizersInUse.length;

        for(var i:int=size-1; i>=0; i--){
            _resizersInUse[i].hide();
            _availableResizers[_availableResizers.length] = _resizersInUse.pop();
        }

        _resizers = {};
    }

    /**
     *
     */

    protected function showResizers():void{
        var el:ILayoutResizer;

        for each(var m:ResizerModel in _resizers){
            el = _availableResizers.length ? _availableResizers.pop() : createResizer();

            if(!el) continue;

            el.model = m;
            el.show();
            _resizersInUse.push(el);
        }
    }

    /**
     *
     */

    protected function prepareResizers():void{
        _resizersID && clearTimeout(_resizersID);
        _resizersID = setTimeout(showResizers,200);
    }

    /**
     *
     * @return
     */


    protected function createResizer():ILayoutResizer{

        if(!(_resizersFun is Function)) return null;

        _waitForRes++;
        var r:ILayoutResizer = _resizersFun(resizerCreated);

        return r;

    }


    /**
     *
     * Pass this to resizer generator
     *
     * @param e
     */

    private function resizerCreated(e:FlexEvent):void{

        const target:EventDispatcher = (e.target as EventDispatcher);

        if(!target) return;

        target.removeEventListener(FlexEvent.CREATION_COMPLETE,resizerCreated);

        _availableResizers.push(target);

        _waitForRes--;

        if(!_waitForRes) showResizers();
    }


    /**
     *  Resize group
     * @param key
     * @param delta
     */

    public function resizeGroup(key:String, delta:int, dispatch:Boolean = true):void {
        _model.resize_group(key, delta);

        dispatch && dispatchLocalChanges("resize",{key:key,d:delta});

        updateDisplayList();
    }


    /**
     * Add element to automatically defined position
     *
     * @param element
     */

    public function autoAddElement(element:ITreeLayoutElement):void {

        var maxS:int = 1;
        var maxEl:ITreeLayoutElement;

        for each (var el:ITreeLayoutElement in _model.elements) {

            if (maxS < el.width * el.height) {
                maxS = el.width * el.height;
                maxEl = el;
            }

        }

        // calculate drop direction
        var dir:uint;

        if (maxEl && maxEl.width > maxEl.height)
            dir = DragDirection.LEFT;
        else
            dir = DragDirection.UP;

        addElement(element, maxEl, dir);
    }


    /**
     *
     * Adds element to the model
     *
     * @param element instance to add
     * @param elementTo dropholder instance
     * @param direction direction of drop (DragDirection.RIGHT | DragDirection.LEFT | DragDirection.DOWN | DragDirection.UP)
     *
     * @see getElementUnderPoint
     *
     */



    public function addElement(element:ITreeLayoutElement, elementTo:ITreeLayoutElement, direction:uint, dispatch:Boolean = false):void {

        var layout:uint = DragDirection.getLayoutDirectionByValue(direction);
        var index:uint = DragDirection.getLayoutIndexByValue(direction);

        var w:int = 100;
        var h:int = 100;

        if (layout == 0)
            w = 50;
        else
            h = 50;


        var _data:LayoutElementData = new LayoutElementData(w, h, element.elementId, layout);
        if (_model.num == 0)
            _model.init(_data);
        else if (elementTo.elementId == 0) {
            _model.addAbove(_data, index, layout);
            if (layout == 0)
                _data.width = 25;
            else
                _data.height = 35;
        } else
            _model.add(elementTo.layoutIndex, _data, index, layout);

        var type:String = "move";

        if (initElement(element)) {
            type = "add";
        }

        element.visible = true;

        dispatch && dispatchLocalChanges(type,{
                    to: elementTo.elementId,
                    from: element.elementId,
                    i: index,
                    l: layout,
                    data: _data
                });

        updateDisplayList();
    }


    /** Removes element from the model and (if not <i>weak</i>) from the container.'
     *
     * @param element element to remove
     * @param weak if <i>false</i> then element will be removed from the container;  otherwise not. Use <i>true</i> when dragging modules. Commits layout model if <i>true</i>.
     */

    public function removeElement(element:ITreeLayoutElement, weak:Boolean = true, dispatch:Boolean = true):void {
        if (_expandedTarget == element) _expanded = false;

        weak && (_prevModel = _model.clone());

        _model.remove(element.layoutIndex);
        element.visible = false;
        if (!weak){
            delete _model.elements[element.elementId];
        }

        dispatch && dispatchLocalChanges("remove", {from:element.elementId});

        updateDisplayList();

    }



    /** Expand module
     *
     * @param module
     * @param update display list immediately or skip
     *
     */

    public function expand(element:ITreeLayoutElement, update:Boolean = true):void {

        if (_expanded)
            return;

        _expandedTarget = element;

        _expanded = true;

        update && updateDisplayList();
    }


    /** Minimize expanded module
     *
     * @param module
     *
     */

    public function minimize(module:ITreeLayoutElement):void {

        if (!_expanded || (_expandedTarget != module))
            return;

        _expanded = false;

        updateDisplayList();
    }


    //------------ for server events handling ------------//


    tb_internal function removeByID(id:uint):void {
        if (!exists(id))
            return;
        removeElement(_model.elements[id], false, false);
    }

    tb_internal function add(elementId:uint,to:uint,layout:uint,index:uint):void{

        if(!exists(to)) return;

        addElement(_model.elements[elementId] as ITreeLayoutElement, _model.elements[to] as ITreeLayoutElement, getDropDirectionByLayoutIndex(layout,index),false);
    }


    tb_internal function resize(key:String, delta:Number):void{
        resizeGroup(key,delta,false);
    }

    tb_internal function move(from:uint, to:uint, layout:uint, index:uint):void {

        if (!exists(from) || !exists(to))
            return;

        var fromElement:ITreeLayoutElement = _model.elements[from] as ITreeLayoutElement;

        var data:LayoutElementData = _model.tree.find(fromElement.layoutIndex).data as LayoutElementData;

        _model.remove(fromElement.layoutIndex);
        updateDisplayList();


        var toElement:ITreeLayoutElement = _model.elements[to] as ITreeLayoutElement;

        data.height = 100;
        data.width = 100;
        data.layout = layout;
        if (layout === 0)
            data.width = 50;
        else
            data.height = 50;

        if (to === 0)
            _model.addAbove(data, index, layout);
        else
            _model.add(toElement.layoutIndex, data, index, layout);

        updateDisplayList();
    }


    tb_internal function expandByKey(key:String):void {
        var data:LayoutElementData = _model.tree.find(key).data as LayoutElementData;
        data && expand(_model.elements[data.id]);
    }


    tb_internal function minimizeByKey(key:String):void {
        var data:LayoutElementData = _model.tree.find(key).data as LayoutElementData;
        data && minimize(_model.elements[data.id]);
    }



    private function dispatchLocalChanges(type:String,data:Object):void{
        var ldata:LayoutChangeData = new LayoutChangeData(data);
        ldata.type = type;
        dispatchEvent(new LayoutEvent(LayoutEvent.CHANGE,ldata));
    }

    /**
     * Returns element under point and direction of drop.
     *
     * @param pt Point
     *
     * @return Object({direction:DragDirection.LEFT|RIGHT|UP|DOWN, element:IModuleInstance})
     *
     */


    public function getElementUnderPoint(pt:Point):Object {


        if (_model.num <= 0)
            return null;

        var target:ITreeLayoutElement;
        var direction:uint;

        if (_model.num === 1) {
            target = getElementById((_model.tree.data as LayoutElementData).id);
            direction = getDropDirection(pt.x, pt.y, _container.width / 2, _container.height / 2, _container.width, _container.height);
            return {element: target, direction: direction};
        }

        if (pt.x < bordersDelta || pt.y < bordersDelta || _container.width - pt.x < bordersDelta || _container.height - pt.y < bordersDelta) {
            direction = getDropDirection(pt.x, pt.y, _container.width / 2, _container.height / 2, _container.width, _container.height);
            return {element: _container, direction: direction};
        }

        var x:int = 0;
        var y:int = 0;
        var flag:Boolean = true;

        var _node:TreeNode = _model.tree.left;

        width = _container.width + _gap;
        height = _container.height + _gap;

        while (flag) {
            if (pt.x > x + width * ((_node.data as LayoutElementData).width / 100) || pt.y > y + height * ((_node.data as LayoutElementData).height / 100)) {
                if ((_node.parent.data as LayoutElementData).layout === 1)
                    y += height * ((_node.data as LayoutElementData).height / 100) + _gap;
                else
                    x += width * ((_node.data as LayoutElementData).width / 100) + _gap;

                _node = _node.parent.right;
            }

            if (!_node.hasChildren) {

                target = getElementById((_node.data as LayoutElementData).id);
                width = width * ((_node.data as LayoutElementData).width / 100);
                height = height * ((_node.data as LayoutElementData).height / 100);
                direction = getDropDirection(pt.x, pt.y, x + width / 2, y + height / 2, width, height);

                if ((direction === DragDirection.LEFT || direction === DragDirection.RIGHT) && target.width / 2 < (this.width / contMinWidth) * minWidth
                        ||
                        (direction === DragDirection.UP || direction === DragDirection.DOWN) && target.height / 2 < (this.height / contMinHeight) * minHeight
                        )
                    return null;

                return {element: target, direction: direction};
            }
            else {
                width *= ((_node.data as LayoutElementData).width / 100);
                height *= ((_node.data as LayoutElementData).height / 100);
                _node = _node.left;
            }
        }

        return null;
    }


    public function updateDisplayList():void {


        if (_model.num <= 0 || !this.active)
            return;

        hideResizers();


        height = _container.height;
        width = _container.width;


        _minW = minWidth * (width / contMinWidth);
        _minH = minHeight * (height / contMinHeight);

        if (_expanded) {
            _expandedTarget.setLayoutBoundsSize(width, height);
            _expandedTarget.setLayoutBoundsPosition(0, 0);
            return;
        }


        var target:ITreeLayoutElement;

        if (_model.num === 1) {
            target = getElementById((_model.tree.data as LayoutElementData).id);
            if (!target)
                return;
            target.setLayoutBoundsSize(_container.width, _container.height);
            target.setLayoutBoundsPosition(0, 0);
            target.layoutIndex = "";
            return;
        }


        var x:int = 0;
        var y:int = 0;
        var right:Boolean = false;
        var flag:Boolean = true;
        var l:uint = 0;
        var paramsStack:Stack = new Stack();

        var _node:TreeNode = _model.tree;

        width = _container.width + _gap;
        height = _container.height + _gap;

        paramsStack.pushObj(width, height);

        while (flag) {
            l = (_node.data as LayoutElementData).layout;

            if (!right) {
                _node = _node.left;
                width = LayoutUtils.accuratePercentMultiply(width, (_node.data as LayoutElementData).width);
                height = LayoutUtils.accuratePercentMultiply(height, (_node.data as LayoutElementData).height);
            } else {

               !_locked && _resizersFun && initResizer(
                        _node.key
                        , (_node.data as LayoutElementData).layout
                        , width
                        , height
                        , x - (1 - (_node.data as LayoutElementData).layout) * _gap * 1.5
                        , y - (_node.data as LayoutElementData).layout * _gap * 1.5
                        , width * ((_node.right.data as LayoutElementData).width / 100)
                        , height * ((_node.right.data as LayoutElementData).height / 100)
                );

                _node = _node.right;
                width *= ((_node.data as LayoutElementData).width / 100);
                height *= ((_node.data as LayoutElementData).height / 100);
            }


            paramsStack.pushObj(width, height);


            if (!_node.hasChildren) {
                target = getElementById((_node.data as LayoutElementData).id);
                if (!target)
                    return;
                target.layoutIndex = _node.key;
                target.setLayoutBoundsSize(width - _gap,height - _gap);
                target.setLayoutBoundsPosition(x, y);
               // target.width = width - _gap;
               // target.height = height - _gap;

                var tempObj:Object = paramsStack.pop();


                if (right) {
                    x += width;
                    y += height;

                    while (_node.type === 1) {
                        tempObj = paramsStack.pop();
                        _node = _node.parent;
                    }

                    if (_node.type === 2)
                        flag = false;
                    else {
                        var tempW:int = tempObj.width;
                        var tempH:int = tempObj.height;
                        width = paramsStack.top().width;
                        height = paramsStack.top().height;
                        _node = _node.parent;

                        if ((_node.data as LayoutElementData).layout === 0)
                            y -= tempH;
                        else
                            x -= tempW;

                    }
                }
                else {
                    if (l === 1)
                        y += height;
                    else
                        x += width;

                    width = paramsStack.top().width;
                    height = paramsStack.top().height;
                    _node = _node.parent;
                    right = true;
                }
            }
            else
                right = false;
        }


        !_locked && _resizersFun && prepareResizers();

    }


    private function getDropDirection(x:int, y:int, x2:int, y2:int, w:int, h:int):uint {

        var pt:Point = new Point();

        pt.x = h * (x - x2) - w * (y - y2);
        pt.y = w * (x - x2) + h * (y - y2);


        if (pt.x > 0 && pt.y > 0)
            return DragDirection.RIGHT;

        if (pt.x > 0 && pt.y < 0)
            return DragDirection.UP;

        if (pt.x < 0 && pt.y > 0)
            return DragDirection.DOWN;

        if (pt.x < 0 && pt.y < 0)
            return DragDirection.LEFT;


        return null;
    }


    private function getDropDirectionByLayoutIndex(layout:uint, index:uint):uint {

        if (layout == 0){
            if(index == 0)
                return DragDirection.LEFT;
            else
                return DragDirection.RIGHT;
        }else{
            if(index == 0)
                return DragDirection.UP;
            else
                return DragDirection.DOWN;
        }

        return null;
    }

    private function getElementById(id:int):ITreeLayoutElement {

        return (_model.elements[id] != undefined) ? _model.elements[id] : null;

    }


    private function exists(id:uint):Boolean {
        return !(_model.elements[id] == undefined) || !id;
    }


    public function get width():int {
        return _width;
    }


    public function get height():int {
        return _height;
    }


    public function get model():LayoutModel {
        return _model;
    }

    public function set width(value:int):void {
        _width = value;
    }

    public function set height(value:int):void {
        _height = value;
    }

    public function get initialized():Boolean {
        return _initialized;
    }

    public function get active():Boolean {
        return _active;
    }

    public function set active(value:Boolean):void {
        _active = value;
        updateDisplayList();
        dispatchEvent(new LayoutEvent(LayoutEvent.ACTIVE));
    }

    public function get locked():Boolean {
        return _locked;
    }

    public function set locked(value:Boolean):void {
        _locked = value;
        updateDisplayList();
        dispatchEvent(new LayoutEvent(LayoutEvent.LOCK));
    }
}
}
