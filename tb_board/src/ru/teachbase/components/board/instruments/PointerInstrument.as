package ru.teachbase.components.board.instruments {
import flash.display.DisplayObjectContainer;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.geom.Rectangle;

import mx.core.EventPriority;

import ru.teachbase.assets.wb.PointerCursor;

import ru.teachbase.behaviours.dragdrop.DragBehavior;
import ru.teachbase.behaviours.dragdrop.DragEvent;
import ru.teachbase.components.board.BoardCanvas;
import ru.teachbase.components.board.FigureManager;
import ru.teachbase.components.board.model.Figure;

/**
 * @author Vova Dem (created: Sep 17, 2012)
 */
public class PointerInstrument extends Instrument {

    //------------ constructor ------------//

    private var _drag:DragBehavior;
    private var _dragRect:Rectangle;

    private var _currentFigure:Figure;

    private var _frameContainer:Sprite;

    private var _dragging:Boolean = false;

    private var _start:Point;

    public function PointerInstrument() {
        super(InstrumentType.POINTER);
        _cursor = (new PointerCursor()).toDisplayObject();
        _cursorY = 19;
        _cursorX = 2;

    }

    //------------ initialize ------------//

    internal static function initialize():void {
        registerClass(InstrumentType.POINTER, PointerInstrument);
    }

    override public function initialize(manager:FigureManager):void {
        super.initialize(manager);

        if (super.manager && target){
            target.addEventListener(MouseEvent.MOUSE_DOWN, detectFigureHandler, true, EventPriority.CURSOR_MANAGEMENT);
            target.addEventListener(MouseEvent.MOUSE_OVER, detectOverHandler, true, EventPriority.CURSOR_MANAGEMENT);
            _drag = new DragBehavior();
            _drag.active = true;
            _drag.useCapture = false;
            _drag.considerParent = false;

            _drag.addEventListener(DragEvent.DRAG_START, dragStartHandler);
            _drag.addEventListener(DragEvent.DRAG_END, dragStopHandler);
            _dragRect = new Rectangle();

            _frameContainer = new Sprite();
            _frameContainer.mouseEnabled = false;
        }
    }

    override public function dispose():void {
        if (target){
            target.removeEventListener(MouseEvent.MOUSE_DOWN, detectFigureHandler, true);
            target.removeEventListener(MouseEvent.MOUSE_OVER, detectOverHandler, true);
            target.removeEventListener(MouseEvent.CLICK, canvasClickHandler);
            target.removeEventListener(MouseEvent.CLICK, figureClickHandler, true);
            _drag.removeEventListener(DragEvent.DRAG_START, dragStartHandler);
            _drag.removeEventListener(DragEvent.DRAG_END, dragStopHandler);
            _drag.dispose();
            _dragging = false;
            hideFrame(_currentFigure);
        }
        super.dispose();
    }

    //--------------- handlers -----------//

    private function detectFigureHandler(e:MouseEvent):void {

        if (e.target is Figure) {

            const fig:Figure = e.target as Figure;
            const canv:BoardCanvas = target as BoardCanvas;

            _currentFigure = fig;

            _currentFigure.removeEventListener(MouseEvent.MOUSE_OVER, figureOutHandler);
            target.removeEventListener(MouseEvent.MOUSE_OVER, detectOverHandler, true);
            target.addEventListener(MouseEvent.CLICK, canvasClickHandler);
            target.addEventListener(MouseEvent.CLICK, figureClickHandler, true, EventPriority.CURSOR_MANAGEMENT);


            const bounds:Rectangle = _currentFigure.getBounds(_currentFigure);

            _dragRect.setTo(-bounds.x*fig.scaleDelta,-bounds.y*fig.scaleDelta,canv.formatBounds.width - (bounds.width)*fig.scaleDelta,canv.formatBounds.height - (bounds.height)*fig.scaleDelta);

            _drag.virtualBounds = _dragRect;
            _drag.target = fig;

            _dragging = true;

            drawFrame(_currentFigure);

        }
    }


    private function detectOverHandler(e:MouseEvent):void {

        if(_dragging) return;

        if (e.target is Figure) {

            const fig:Figure = e.target as Figure;

            fig.addEventListener(MouseEvent.MOUSE_OUT, figureOutHandler);

            drawFrame(fig, .5);

            e.stopImmediatePropagation();

        }
    }

    private function figureClickHandler(e:MouseEvent):void{

        if(e.target is Figure){
            target.addEventListener(MouseEvent.MOUSE_OVER, detectOverHandler, true, EventPriority.CURSOR_MANAGEMENT);
            e.stopImmediatePropagation();
        }

    }

    private function canvasClickHandler(e:MouseEvent):void{

        target.addEventListener(MouseEvent.MOUSE_OVER, detectOverHandler, true, EventPriority.CURSOR_MANAGEMENT);
        _currentFigure && hideFrame(_currentFigure);
        _dragging = false;

        target.removeEventListener(MouseEvent.CLICK, canvasClickHandler);
        target.removeEventListener(MouseEvent.CLICK, figureClickHandler, true);
    }


    private function figureOutHandler(e:MouseEvent):void{
        if(_dragging) return;

        e.target.removeEventListener(MouseEvent.MOUSE_OUT,figureOutHandler);
        _frameContainer && hideFrame(e.target as DisplayObjectContainer);
    }

    private function dragStartHandler(e:DragEvent):void{

        if(!_currentFigure) return;

        manager.bringToFront(_currentFigure);

        _start = new Point(_currentFigure.x, _currentFigure.y);

    }

    private function dragStopHandler(e:DragEvent):void{

        if(!_currentFigure) return;

        _dragging = false;

        manager.moveFigure(_currentFigure.id, new Point((_currentFigure.x - _start.x)/_currentFigure.scaleDelta,(_currentFigure.y - _start.y)/_currentFigure.scaleDelta));

    }


    //--------------- ctrl ---------------//


    private function drawFrame(tgt:DisplayObjectContainer, alpha:Number = 1):void{

        if(!tgt) return;

        _frameContainer.graphics.clear();

        var bounds:Rectangle = tgt.getBounds(tgt);
        _frameContainer.graphics.lineStyle(1,0x0083eb,alpha);
        _frameContainer.graphics.beginFill(0x0083eb, 0.05);
        _frameContainer.graphics.drawRect(bounds.x, bounds.y, bounds.width, bounds.height);
        _frameContainer.graphics.endFill();

        tgt.addChild(_frameContainer);

    }


    private function hideFrame(tgt:DisplayObjectContainer):void{

        tgt && (_frameContainer.parent === tgt) && tgt.removeChild(_frameContainer);

        _currentFigure = null;
        _drag.target = null;
    }


    //------------ get / set -------------//


}
}