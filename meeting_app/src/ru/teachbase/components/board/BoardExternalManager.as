/**
 * User: palkan
 * Date: 9/26/13
 * Time: 4:51 PM
 */
package ru.teachbase.components.board {
import mx.rpc.Responder;

import ru.teachbase.components.board.model.IExternalBoardManager;
import ru.teachbase.constants.PacketType;
import ru.teachbase.manage.rtmp.RTMPListener;
import ru.teachbase.manage.rtmp.events.RTMPEvent;
import ru.teachbase.manage.rtmp.model.Recipients;
import ru.teachbase.utils.helpers.getValue;
import ru.teachbase.utils.helpers.isArray;
import ru.teachbase.utils.shortcuts.$null;
import ru.teachbase.utils.shortcuts.rtmp_history;
import ru.teachbase.utils.shortcuts.rtmp_send;

public class BoardExternalManager implements IExternalBoardManager {

    private var _listener:RTMPListener;

    private var _id:int;

    private var _mgr:FigureManager;

    public function BoardExternalManager(id:int){
        _id = id;
        _listener = new RTMPListener(PacketType.WHITEBOARD+"::"+_id);
    }


    public function connect(mgr:FigureManager):void{

        _mgr = mgr;

        _listener.initialize();
        _listener.addEventListener(RTMPEvent.DATA, handleMessage);

        rtmp_history(PacketType.WHITEBOARD+"::"+_id, new Responder(handleHistory,$null));

    }


    public function send(data:Array):void{
        rtmp_send(PacketType.WHITEBOARD+"::"+_id,data,Recipients.ALL_EXCLUDE_ME);
    }


    public function dispose():void{

        _listener.removeEventListener(RTMPEvent.DATA, handleMessage);
        _listener.dispose();

        _mgr = null;

    }



    private function handleHistory(data:Object):void{

        _mgr.setupHistory(
              getValue(data,"figures",[],isArray),
              getValue(data,"history",[],isArray),
              getValue(data,"position",0)
        );

        _listener.readyToReceive = true;
    }


    private function handleMessage(e:RTMPEvent):void{

        const data:Array = e.packet.data as Array;

        if(!data) return;

        _mgr.receiveExternalData(data);

    }

}
}
