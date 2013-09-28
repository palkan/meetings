package ru.teachbase.components.board {
import flash.display.DisplayObjectContainer;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.geom.Point;

import mx.managers.CursorManager;
import mx.managers.CursorManagerPriority;

import ru.teachbase.components.board.components.BoardTextInput;
import ru.teachbase.components.board.instruments.DrawInstrument;
import ru.teachbase.components.board.instruments.Instrument;
import ru.teachbase.components.board.instruments.InstrumentType;
import ru.teachbase.components.board.instruments.TextInstrument;
import ru.teachbase.components.board.model.*;
import ru.teachbase.components.board.style.FillStyle;
import ru.teachbase.components.board.style.StrokeStyle;
import ru.teachbase.utils.DelayedWriter;

use namespace _figures;

/**
 * @author Webils (created: Mar 20, 2012)
 */
public class FigureManager {

    private const externals:Vector.<ExternalFigure> = new Vector.<ExternalFigure>();

    //----- private --------//

    private var _history:BoardHistory;
    private var _currentInstrument:Instrument;
    private var _currentInstrumentType:String;


    //----- properties ------//

    private var _canvas:BoardCanvas;

    //----- external -------//

    private var _extmgr:IExternalBoardManager;
    private var _sender:DelayedWriter;



    //------------ constructor ------------//

    public function FigureManager() {

        new BoardUpdateData();
        new StyleData();

        _history = new BoardHistory(this);
    }

    //------------ initialize ------------//

    /**
     * Associate manager with canvas.
     *
     * @param canvas
     */

    public function initialize(canvas:BoardCanvas):void {
        _canvas = canvas;
        _canvas._figures::setManager(this);
    }

    /**
     * Dispose manager (clean memory).
     */


    public function dispose():void {
        externals.length = 0;
        _history.dispose();
        _canvas && _canvas.dispose();
    }

    //--------------- internal API ---------------//

    /**
     *
     * @param position:Point initial position of new figure
     * @param draw:Function must be link to function:<br/>
     * <code>
     * function draw(firstPointIndex:int = 0, length:int = int.MAX_VALUE):void
     * </code>
     * @return new figure
     * @private
     * @see Figure.Figure()
     */
    public function createFigure(position:Point, draw:Function, instrument:Instrument, __id:String = null, page:int = -1, style:StyleData = null):IFigure {
        const figure:Figure = new Figure(draw, instrument.tid, _canvas.formatBounds.width);
        figure.x = position.x;
        figure.y = position.y;


        // make clone from user-style:
        var stroke_style:StrokeStyle = canvas.stroke.clone() as StrokeStyle;
        var fill_style:FillStyle = canvas.fill.clone() as FillStyle;


        if(style){
            stroke_style.thickness = style.stroke;
            stroke_style.color = style.color;
            fill_style.color = style.fillColor;
        }

        figure.thickness = stroke_style.thickness;
        figure.color = stroke_style.color;
        figure.fillColor = fill_style.color;

        var cont:Sprite;

        if (page >= 0) {
            cont = _canvas.getPage(page).figureContainer;
            figure.page_id = _canvas.page.pageId;
        } else {
            cont = _canvas.page.figureContainer;
            figure.page_id = _canvas.page.pageId;
        }

        cont.addChild(figure);

        // externals:
        const external:ExternalFigure = new ExternalFigure(this, figure, __id);
        externals.push(external);
        external.ignorLocalChanges = !!__id;

        _history.push({type: "add", id: figure.external.id});

        return figure;
    }

    /**
     * Create Figure with text input.
     *
     * @param position
     * @param __id
     * @param page
     * @param color
     * @return
     *
     * @private
     */


    public function createText(position:Point, __id:String = null, page:int = -1, style:StyleData = null):IFigure {
        const figure:Figure = new Figure(null, InstrumentType.TEXT, TextInstrument.FIXED_WIDTH);
        figure.x = position.x;
        figure.y = position.y;

        figure.scaleRelativeCanvasWidth(_canvas.formatBounds.width);

        // make clone from user-style:
        var stroke_style:StrokeStyle = canvas.stroke.clone() as StrokeStyle;


        if (style)
            stroke_style.color = style.color;

        figure.color = stroke_style.color;

        var cont:Sprite;

        if (page >= 0) {
            cont = _canvas.getPage(page).textContainer;
            figure.page_id = page;
        } else {
            cont = _canvas.page.textContainer;
            figure.page_id = _canvas.page.pageId;
        }

        cont.addChild(figure);

        var _txt:BoardTextInput = new BoardTextInput(figure);

        figure.textField = _txt;
        figure.addChild(_txt);

        // externals:
        const external:ExternalFigure = new ExternalFigureText(this, figure, __id);
        externals.push(external);
        external.ignorLocalChanges = !!__id;

        _history.push({type: "add", id: figure.external.id});

        return figure;
    }


    /**
     *
     * Remove figure by id.
     *
     * @param id
     * @param local
     * @param inHistory
     *
     * @private
     */

    public function removeFigure(id:String, local:Boolean = true, inHistory:Boolean = true):void {

        var fig:Figure = getFigureByID(id) as Figure;

        if (fig) {

            if (fig.instrument === InstrumentType.TEXT)
                _canvas.page.textContainer.removeChild(fig);
            else
                _canvas.page.figureContainer.removeChild(fig);

            local && localChanges("remove",fig.external);

            inHistory && _history.push({type: "remove", id: fig.external.id});
        }

    }


    /**
     *
     * Add figure by id (from history).
     * @param id
     * @private
     */


    private function addFigure(id:String):void {

        var _f:Figure = getFigureByID(id) as Figure;

        if (_f) {

            if (_f.instrument === InstrumentType.TEXT)
                _canvas.page.textContainer.addChild(_f);
            else
                _canvas.page.figureContainer.addChild(_f);

        }

    }

    /**
     *
     * @param id
     * @param delta
     * @param local
     * @param inHistory
     *
     * @private
     */


    public function moveFigure(id:String, delta:Point, local:Boolean = true, inHistory:Boolean = true):void{
        var _f:Figure = getFigureByID(id) as Figure;

        if (_f) {

            inHistory && _history.push({type:"move",id:id, data:_f.initialPosition.clone()});

             _f.moved(delta.x,delta.y);

            local && localChanges("move", _f.external, _f.initialPosition);

            if(!local){
                bringToFront(_f);
                _f.scaleRelativeCanvasWidth(_canvas.formatBounds.width);
            }

        }
    }


    /**
     *
     * A long and winding path to send update to external...
     *
     * @param figure
     *
     * @private
     */

    public function completeFigure(figure:IFigure):void {
        figure.complete = true;
    }


    /**
     *
     * Remove figure from history and from memory.
     *
     * @param id
     *
     * @private
     */


    public function completeRemove(id:String):void {

        var _f:Figure = getFigureByID(id) as Figure;

        if (_f) {
            externals.splice(externals.indexOf(_f.external), 1);
        }
    }

    /**
     *
     * Bring figure to front (used when moving figures).
     *
     * @param figure
     *
     * @private
     */


    public function bringToFront(figure:Figure):void{

        const cont:DisplayObjectContainer = _canvas.getPage(figure.page_id).figureContainer;

        (figure.parent === cont) && cont.setChildIndex(figure,cont.numChildren-1);

    }


    /**
     * Works for all figures
     *
     * @private
     */
    public function scaleRelativeCanvasWidth(value:Number):void {
        for each(var external:ExternalFigure in externals)
            external.figure && external.figure.scaleRelativeCanvasWidth(value);
    }


    /**
     *
     * @param obj
     * @param local
     *
     * @private
     */

    public function handleUndo(obj:Object, local:Boolean = true):void {

        if (!obj)
            return;

        var _f:Figure = getFigureByID(obj.id) as Figure;

        if(!_f) return;

        if (obj.type === "add")
            removeFigure(obj.id, false, false);
        else if (obj.type === "remove")
            addFigure(obj.id);
        else if(obj.type === "move")
            moveFigure(obj.id,(obj.data as Point).subtract(_f.initialPosition),false,false);


        local && localChanges("history",_f.external,"undo");
    }


    /**
     *
     * @param obj
     * @param local
     *
     * @private
     */

    public function handleRedo(obj:Object, local:Boolean = true):void {

        if (!obj)
            return;

        var _f:Figure = getFigureByID(obj.id) as Figure;

        if(!_f) return;

        if (obj.type === "remove")
            removeFigure(obj.id, false, false);
        else if (obj.type === "add")
            addFigure(obj.id);
        else if(obj.type === "move")
            moveFigure(obj.id,(obj.data as Point).subtract(_f.initialPosition),false,false);

        local && localChanges("history",_f.external,"redo");

    }


    //------------------ API: drawing ---------------------//

    /**
     *  Undo action.
     */

    public function undo():void{
        handleUndo(_history.undo());
    }

    /**
     *  Redo action.
     */

    public function redo():void{
        handleRedo(_history.redo());
    }


    /**
     * Activate board instrument.
     *
     * If nothing or <code>null</code> is passed than deactivate current instrument.
     *
     * @param id
     *
     * @see InstrumentType
     */


    public function setInstrument(id:String = null):void{

        if (_currentInstrumentType == id)
            return;

        _currentInstrumentType = null;

        if (_currentInstrument){
            currentInstrument.dispose();
            currentInstrument = null;
        }

        if (!id) return;

        _currentInstrumentType = id;

        const newInstrument:Instrument = Instrument.get(_currentInstrumentType, _canvas);

        _currentInstrument = newInstrument;
        _currentInstrument && _currentInstrument.initialize(this);

    }


    /**
     *
     * Change style value.
     *
     * Available styles are "color" : uint, "stroke" : Number, "background" : uint.
     *
     * @param style_id
     * @param value
     */

    public function setStyle(style_id:String, value:*):void{
        _canvas && _canvas.setStyle(style_id,value);
    }

    /**
     *
     * @param id
     */

    public function goToPage(id:int):void{
        _canvas && _canvas.goToPage(id);
    }

    /**
     *
     */

    public function enable():void{
        _canvas && (_canvas.editable = true);
    }

    /**
     *
     */

    public function disable():void{
        _canvas && (_canvas.editable = false);
        currentInstrument && currentInstrument.dispose();
        currentInstrument = null;
    }


    //------------------ API: external -------------------//

    /**
     *
     * SEt external manager for sending and receiving changes. Callback-driven.
     *
     * @param mgr
     */


    public function setExternal(mgr:IExternalBoardManager):void{

        if(!mgr){
            _extmgr = null;
            _sender = null;
            return;
        }

        _extmgr = mgr;
        _extmgr.connect(this);

        _sender = new DelayedWriter(500, function(data:Array):void{
            _extmgr.send(data);
        });

        _sender.mode = DelayedWriter.COLLECT;


    }

    /**
     *
     * Setup initial state from external data.
     *
     * @param figures
     * @param hist
     * @param h_position
     */

    public function setupHistory(figures:Array, hist:Array, h_position:int = 0):void {

        receiveExternalData(figures);

        _history.clear();

        for each(var el:Object in hist)
            _history.push(el);

        while (h_position < 0) {
            handleUndo(_history.undo(), false);
            h_position++;
        }
    }

    public function receiveExternalData(changes:Array):void {

        for each(var data:BoardUpdateData in changes) {

            this["ext_"+data.action](data.fid,data.data);

        }

    }



    //--------------- External callbacks -------------//




    private function ext_history(fid:String, type:String):void{
        this[type](_history[type](), false);
    }

    private function ext_remove(fid:String, data:* = null):void{
        removeFigure(fid,false);
    }

    private function ext_soft_remove(fid:String, data:* = null):void{
        removeFigure(fid,false,false);
    }

    private function ext_move(fid:String, data:Object):void{

        const fig:Figure = getFigureByID(fid) as Figure;

        if(!fig) return;

        moveFigure(fid,(data as Point).subtract(fig.initialPosition),false);

    }

    private function ext_create(fid:String, data:Object):void{

        var oldInstrument:Instrument = currentInstrument;
        const instrument:Instrument = Instrument.get(data.instrument, canvas);
        instrument.initialize(this);
        var fig:IFigure;
        if (instrument is TextInstrument)
            fig = createText(data.position, fid, data.page_id, data.style);
        else
            fig = createFigure(data.position, instrument.getModifierFunction(), instrument, fid, data.page_id, data.style);

        fig.external.updateProperties(data);

        instrument is DrawInstrument && (instrument as DrawInstrument).doCompleteFigure(fig);
        instrument.dispose();

        if (oldInstrument) {
            currentInstrument = Instrument.get(oldInstrument.tid, canvas);
            currentInstrument.initialize(this);
        } else {
            currentInstrument = null;
        }

        fig.scaleRelativeCanvasWidth(_canvas.formatBounds.width);

    }

    private function ext_data(fid:String, data:Object):void{

        const fig:IFigure = getFigureByID(fid);

        if(!fig) return;

        fig.external.updateProperties(data);

    }


    //---------------- private ------------------//

    private function getFigureByID(id:String):IFigure {
        for each(var external:ExternalFigure in externals) {
            if (external.figure && external.figure.id == id)
                return external.figure;
        }
        return null;
    }


    private function setCursor(event:MouseEvent = null):void {

        if (!_currentInstrument)
            return;

        BoardCursor.icon = _currentInstrument.cursor;

        if (BoardCursor.icon)
            CursorManager.setCursor(BoardCursor, CursorManagerPriority.HIGH, _currentInstrument.cursorX, _currentInstrument.cursorY);
        else
            CursorManager.removeAllCursors();
    }


    //------------ get / set -------------//

    public function get canvas():BoardCanvas {
        return _canvas;
    }

    //------- handlers / callbacks -------//

    /**
     *
     * @param action
     * @param external
     * @param changes
     */

    _figures function localChanges(action:String, external:ExternalFigure, changes:* = null):void {

        _sender && _sender.write(new BoardUpdateData(action, external ? external.id : "", changes));

    }

    public function get currentInstrument():Instrument {
        return _currentInstrument;
    }

    public function set currentInstrument(value:Instrument):void {
        if (!value) {
            _currentInstrument && _currentInstrument.dispose();
            CursorManager.removeAllCursors();
            _canvas.removeEventListener(MouseEvent.ROLL_OVER, setCursor);
            _canvas.removeEventListener(MouseEvent.ROLL_OUT, function (e:MouseEvent):void {
                CursorManager.removeAllCursors();
            });
        } else {
            _canvas.addEventListener(MouseEvent.ROLL_OVER, setCursor);
            _canvas.addEventListener(MouseEvent.ROLL_OUT, function (e:MouseEvent):void {
                CursorManager.removeAllCursors();
            });
        }

        _currentInstrument = value;
    }

    [Bindable]
    public function get history():BoardHistory {
        return _history;
    }
}
}