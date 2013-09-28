package ru.teachbase.components.board.instruments {
import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.Stage;
import flash.system.ApplicationDomain;
import flash.utils.getDefinitionByName;
import flash.utils.getQualifiedClassName;

import ru.teachbase.components.board.FigureManager;
import ru.teachbase.components.board.model.ExternalFigure;
import ru.teachbase.components.board.model.Figure;

public class Instrument {
    private var _tid:String;
    private var _target:DisplayObjectContainer;
    private var _active:Boolean;
    private var _manager:FigureManager;

    protected var _cursor:DisplayObject;
    protected var _cursorX:Number = 0;
    protected var _cursorY:Number = 0;

    //------------ constructor ------------//

    public function Instrument(tid:String) {
        _tid = tid;

        // if isn't a subclass:
        if (Object(this).constructor !== Instrument)
            registerInstrument(this);


    }

    //-------- static initialize ---------//


    private static const ids:Array = InstrumentType.ALL;
    private static const classes:Vector.<Class> = new Vector.<Class>();
    private static const instruments:Vector.<Instrument> = new Vector.<Instrument>();

    public static const initialized:Boolean = Boolean(new Instrument(null));

    public static function initialize():void {
        if (!initialized)
            return;

        LineInstrument && LineInstrument.initialize();
        PencilInstrument && PencilInstrument.initialize();

        RectangleInstrument && RectangleInstrument.initialize();
        CircleInstrument && CircleInstrument.initialize();

        TextInstrument && TextInstrument.initialize();

        PointerInstrument && PointerInstrument.initialize();

        MarkerInstrument && MarkerInstrument.initialize();
        EraserInstrument && EraserInstrument.initialize();
    }

    public static function registerInstrument(instrument:Instrument):void {
        if (!instrument) return;

        // need register new instrument?
        const instrumentClassName:String = getQualifiedClassName(instrument);
        if (ApplicationDomain.currentDomain.hasDefinition(instrumentClassName)) {
            const clazz:Class = getDefinitionByName(instrumentClassName) as Class;
            registerClass(instrument.tid, clazz);
            if (!clazz || !instrument.tid)
                return;
        }

        // add to pool:
        if (instruments.indexOf(instrument) === -1)
            instruments.push(instrument);
    }

    private static function registerType(tid:String):uint {
        const index:int = ids.indexOf(tid);
        if (index === -1)
            return ids.push(tid) - 1;
        return index;
    }

    protected static function registerClass(tid:String, instrument:Class):int {
        if (!tid || !instrument)
            return -1;

        const index:uint = registerType(tid);

        if (classes.length <= index)
            classes.length = index + 1;

        // set or override:
        classes[index] = instrument;

        return index;
    }

    public static function get(tid:String, target:DisplayObjectContainer):Instrument {
        if (!tid)
            return null;

        // search in pool:
        const instrument:Instrument = getInstrument(tid, target);
        if (instrument)
            return instrument;

        // search in classes:
        const Clazz:Class = getClass(tid);
        return createInstrumentFromClass(tid, target, Clazz);
    }

    private static function getClass(tid:String):Class {
        const index:int = ids.indexOf(tid);
        if (index !== -1 && classes.length > index && classes[index])
            return classes[index] as Class;
        return null;
    }

    /**
     * return from pool
     */
    private static function getInstrument(tid:String, target:DisplayObjectContainer):Instrument {
        for each(var i:Instrument in instruments)
            if (i.tid === tid && (!i._target || i._target === target)) {
                i._target = target;
                return i;
            }
        ;
        return null;
    }

    private static function createInstrumentFromClass(tid:String, target:DisplayObjectContainer, Clazz:Class):Instrument {
        if (!tid || !Clazz)
            return null;

        const instrument:Instrument = new Clazz() as Instrument;
        registerInstrument(instrument);
        instrument._target = target;
        return instrument;
    }

    //------------ initialize ------------//

    public function initialize(manager:FigureManager):void {
        /*if(_target || _manager)
         dispose();*/

        _manager = manager;

        _manager.currentInstrument = this;

    }

    public function dispose():void {
        _target = null;
        _manager = null;

    }

    //--------------- ctrl ---------------//

    public function getModifierFunction():Function {
        return null;
    }


    public function getExternalFigure(manager:FigureManager, figure:Figure, _id:String):ExternalFigure {


        return new ExternalFigure(manager, figure, _id);

    }


    //------------ get / set -------------//

    public function get tid():String {
        return _tid;
    }

    //--- target
    public function get target():DisplayObjectContainer {
        return _target;
    }

    public function get mouseX():int {
        return _target.mouseX;
    }

    public function get mouseY():int {
        return _target.mouseY;
    }

    public function get stage():Stage {
        return _target.stage;
    }


    public function get active():Boolean {
        return _active;
    }

    public function set active(value:Boolean):void {
        if (_active === value)
            return;

        _active = value;
        // dispatch?
    }

    public function get manager():FigureManager {
        return _manager;
    }

    //------- handlers / callbacks -------//
    public function get cursor():DisplayObject {
        return _cursor;
    }

    public function get cursorY():Number {
        return _cursorY;
    }

    public function get cursorX():Number {
        return _cursorX;
    }
}
}

import ru.teachbase.components.board.instruments.Instrument;

Instrument && /*!Instrument.initialized &&*/ Instrument.initialize();