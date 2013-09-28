package ru.teachbase.components.board.model {
import flash.geom.Point;

import ru.teachbase.components.board.FigureManager;

import ru.teachbase.components.board._figures;
import ru.teachbase.utils.helpers.isList;
import ru.teachbase.utils.helpers.toArray;

/**
 */
public class ExternalFigure {
    private static const ID_PREFIX:String = 'fig:';
    private var _id:String;
    private var _figure:IFigure;
    protected var manager:FigureManager;

    /**
     *
     * Block re-creation of a figure.
     *
     */

    public var ignorLocalChanges:Boolean = false;

    //------------ constructor ------------//

    public function ExternalFigure(manager:FigureManager, figure:IFigure, id:String = null) {
        this._figure = figure;
        figure.external = this;

        this.manager = manager;

        // id = external / self-generated
        _id = id || (ID_PREFIX + new Date().time);
    }

    //------------ initialize ------------//

    //--------------- ctrl ---------------//

    public function sendCreate():void {
        if (ignorLocalChanges) return;

        manager._figures::localChanges("create", this, {
            page_id: (figure as Figure).page_id,
            position: new Point((figure as Figure).x, (figure as Figure).y),
            scale: figure.scaleDelta,
            iw: figure.initialCanvasWidth,
            points: simpliciter(figure.points),
            instrument: figure.instrument,
            style:(figure as Figure).style
        });
    }

    public function sendUpdate(param:String, value:* = null):void {
        manager._figures::localChanges(param,this,value);
    }

    public function pointsUpdated(firstPointIndex:int = 0, length:int = int.MAX_VALUE):void {
        _figure.pointsUpdated(firstPointIndex, length);
    }

    public function updateProperties(changes:Object):void {
        changes.iw && (figure as Figure)._figures::setInitialCanvasWidth(changes.iw);

        for (var key:* in changes.points) {
            figure.setPoint(new FigurePoint(changes.points[key].x, changes.points[key].y), int(key));
        }

        pointsUpdated();
    }


    private function simpliciter(data:*):* {

        if (data is Object) {
            if (data is Point)
                data = {x: data.x, y: data.y};

            else if (data is Function)
                return data = null;

            else
            // simplify self:
            if (isList(data)) {
                data = toArray(data) || data;

                // simplify content:
                for (var key:* in data) {
                    if (key == null) continue;
                    data[key] = simpliciter(data[key]);
                    if (data[key] == null || data[key] == undefined)
                        delete data[key];
                }
            }
        }

        return data;
    }

    //------------ get / set -------------//

    public function get id():String {
        return _id;
    }

    public function get figure():IFigure {
        return _figure;
    }

    //------- handlers / callbacks -------//

}


}