package ru.teachbase.components.board.model {
import flash.geom.Point;

import ru.teachbase.components.board.FigureManager;
import ru.teachbase.components.board._figures;
import ru.teachbase.components.board.instruments.TextInstrument;

public class ExternalFigureText extends ExternalFigure {
    public function ExternalFigureText(manager:FigureManager, figure:IFigure, id:String = null) {
        super(manager, figure, id);
    }

    override public function sendCreate():void {
        if (ignorLocalChanges) return;

        var _x:Number = (figure as Figure).x * (TextInstrument.FIXED_WIDTH / manager.canvas.formatBounds.width);
        var _y:Number = (figure as Figure).y * (TextInstrument.FIXED_WIDTH / manager.canvas.formatBounds.width);

        manager._figures::localChanges("create",this, {
            text: (figure as Figure).textField.text,
            page_id: (figure as Figure).page_id,
            style: (figure as Figure).style,
            position: new Point(_x, _y),
            scale: figure.scaleDelta,
            iw: figure.initialCanvasWidth,
            instrument: figure.instrument});

    }

    override public function updateProperties(changes:Object):void {
        changes.iw && (figure as Figure)._figures::setInitialCanvasWidth(changes.iw);

        changes.text && ((figure as Figure).textField.text = changes.text);

    }
}
}