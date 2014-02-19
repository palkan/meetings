package ru.teachbase.manage.livecursor {

import ru.teachbase.components.board.BoardCanvas;
import ru.teachbase.constants.PacketType;
import ru.teachbase.events.GlobalEvent;
import ru.teachbase.manage.livecursor.model.LiveCursorData;
import ru.teachbase.manage.rtmp.RTMPListener;
import ru.teachbase.manage.rtmp.events.RTMPEvent;
import ru.teachbase.model.App;
import ru.teachbase.model.User;
import ru.teachbase.utils.shortcuts.warning;

/**
 * @author webils (created: May 14, 2012)
 */
public final class LiveCursorManager {
    private const listener:RTMPListener = new RTMPListener(PacketType.CURSOR);

    private const targetsById:Object = {};

    private const targets:Vector.<LiveCursorTarget> = new <LiveCursorTarget>[];

    //------------ constructor ------------//

    public function LiveCursorManager() {

        new LiveCursorData();

        listener.initialize();
        listener.readyToReceive = true;
        listener.addEventListener(RTMPEvent.DATA, handleMessage);

        GlobalEvent.addEventListener(GlobalEvent.USER_LEAVE, userLeaveHandler);
        GlobalEvent.addEventListener(GlobalEvent.PERMISSIONS_UPDATE, permissionsHandler);
    }


    //------------- API ------------------//

    /**
     *
     * @param container
     * @param id
     */

    public function add(container:BoardCanvas, id:int):void {
        if(targetsById[id]){
            warning("Trying to add live cursor target that already exists",id);
            return;
        }

        const target:LiveCursorTarget = new LiveCursorTarget(id,container);
        targets.push(target);
        targetsById[id] = target;

        App.user.isAdmin() && App.user.settings.showcursor && target.activate();
    }

    /**
     *
     * @param id
     */

    public function remove(id:int):void {
        if(!targetsById[id]){
            warning("Trying to remove live cursor target that doesn't exist",id);
            return;
        }

        const target:LiveCursorTarget = targetsById[id];

        targets.splice(targets.indexOf(target),1);
        delete targetsById[id];

        target.deactivate();
        target.dispose();

    }

    /**
     *
     */

    public function enable():void{

        if(!App.user.isAdmin() || !App.user.settings.showcursor) return;

        var i, size;
        for (i = 0, size = targets.length; i < size; i++) targets[i].activate();
    }

    /**
     *
     */

    public function disable():void{
        var i, size;
        for (i = 0, size = targets.length; i < size; i++) targets[i].deactivate();
    }


    //------- handlers / callbacks -------//

    private function userLeaveHandler(e:GlobalEvent):void {

        const uid:Number = (e.value as User).sid;

        var i, size;

        for (i = 0, size = targets.length; i < size; i++) targets[i].userLeft(uid);

    }

    private function permissionsHandler(e:GlobalEvent):void {

        var i, size;

        for (i = 0, size = targets.length; i < size; i++) App.user.isAdmin() ? targets[i].activate() : targets[i].deactivate();

    }


    private function handleMessage(e:RTMPEvent):void {
        const data:LiveCursorData = e.packet.data as LiveCursorData;

        if (targetsById[data.tid]) targetsById[data.tid].processData(data);

    }

}
}