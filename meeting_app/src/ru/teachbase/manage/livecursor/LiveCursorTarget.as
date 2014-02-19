/**
 * User: palkan
 * Date: 2/19/14
 * Time: 2:28 PM
 */
package ru.teachbase.manage.livecursor {
import flash.display.DisplayObjectContainer;
import flash.events.MouseEvent;
import flash.geom.Point;

import ru.teachbase.components.board.BoardCanvas;
import ru.teachbase.constants.PacketType;
import ru.teachbase.manage.livecursor.model.*;
import ru.teachbase.manage.livecursor.model.LiveCursorData;
import ru.teachbase.manage.rtmp.model.Recipients;
import ru.teachbase.model.App;
import ru.teachbase.utils.DelayedWriter;
import ru.teachbase.utils.shortcuts.rtmp_send;

internal class LiveCursorTarget {

    private var container:BoardCanvas;
    private var _id:int;
    private var _active:Boolean = false;
    private var _anchored:Boolean = false;

    private var _cursor:LiveCursor;

    private const cursors:Object = {};

    private const pusher:DelayedWriter = new DelayedWriter(500,sendData);


    public function LiveCursorTarget(id:int, container:BoardCanvas) {
        this.container = container;
        _id = id;
    }


    //----------------- callbacks ------------------//

    public function processData(data:LiveCursorData):void{

        var _cursor:LiveCursor;
        if (!(_cursor = _createCursor(data))) return;

        _cursor.colorize(data.color);

        var _k:Number = initialWidth / data.iw;

        _cursor.move(_k*data.x,_k*data.y,data.anchor);

    }


    public function sendData(point:Object):void{

        const data:LiveCursorData = new LiveCursorData({x:point.x, y:point.y, uid: App.user.sid, tid: _id, iw: initialWidth, color: App.user.settings.color,anchor:_anchored});

        rtmp_send(PacketType.CURSOR, data, Recipients.ALL_EXCLUDE_ME, null, false);
    }


    public function userLeft(uid:Number):void{
        if(cursors[uid]){
            cursors[uid].dispose();
            display.removeChild(cursors[uid]);
            delete cursors[uid];
        }
    }


    public function activate():void{

        if(_active) return;

        _active = true;

        container.addEventListener(MouseEvent.MOUSE_MOVE, moveHandler);
        container.addEventListener(MouseEvent.DOUBLE_CLICK, dblClickHandler);

    }


    public function deactivate():void{

        if(!_active) return;


        !_anchored && container.removeEventListener(MouseEvent.MOUSE_MOVE, moveHandler);
        _anchored && container.removeEventListener(MouseEvent.CLICK, clickHandler);
        container.removeEventListener(MouseEvent.DOUBLE_CLICK, dblClickHandler);

        _active = false;
        anchored = false;
    }

    public function dispose():void{
        for (var key in cursors){
            display.removeChild(cursors[key]);
            cursors[key].dispose();
            delete cursors[key];
        }
    }

    //----------------- handlers -------------------//

    private function moveHandler(e:MouseEvent):void{
       pusher.write({x:container.mouseX,y:container.mouseY,anchor:false});
    }

    private function dblClickHandler(e:MouseEvent):void{
       if(!_anchored){
        container.removeEventListener(MouseEvent.MOUSE_MOVE,moveHandler);
        container.addEventListener(MouseEvent.CLICK, clickHandler);
       }else{
        container.addEventListener(MouseEvent.MOUSE_MOVE,moveHandler);
        container.removeEventListener(MouseEvent.CLICK, clickHandler);
       }

      anchored = !_anchored;

      pusher.write({x:container.mouseX,y:container.mouseY,anchor:_anchored});
    }

    private function clickHandler(e:MouseEvent):void{
        pusher.write({x:container.mouseX,y:container.mouseY,anchor:_anchored});
        cursor.move(container.mouseX,container.mouseY,true);
    }

    //----------------- private ---------------------//

    private function _createCursor(data:LiveCursorData):LiveCursor{
        if(!cursors[data.uid]){

            if(!App.meeting.usersByID[data.uid]) return null;

            cursors[data.uid] = new LiveCursor(data.uid,data.color);
            display.addChild(cursors[data.uid]);
        }
        return cursors[data.uid];
    }



    //----------------- get/set ----------------------//


    private function set anchored(value:Boolean):void{
        if(value)
            cursor.move(container.mouseX,container.mouseY,true);
        else{
            userLeft(App.user.sid)
            _cursor = null;
        }
        _anchored = value;
    }

    private function get cursor():LiveCursor{
        return _cursor || (_cursor = _createCursor(new LiveCursorData({uid:App.user.sid,color:App.user.settings.color})));
    }

    private function get display():DisplayObjectContainer{
        return container.cursorContainer;
    }

    private function get initialWidth():Number{
        return container.formatBounds.width;
    }

    public function get id():int {
        return _id;
    }
}
}
