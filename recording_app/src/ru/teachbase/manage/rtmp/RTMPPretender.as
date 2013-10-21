/**
 * User: palkan
 * Date: 10/17/13
 * Time: 11:24 AM
 */
package ru.teachbase.manage.rtmp {
import flash.events.ErrorEvent;
import flash.events.Event;

import mx.rpc.IResponder;

import ru.teachbase.components.board.model.BoardUpdateData;
import ru.teachbase.components.board.model.StyleData;
import ru.teachbase.layout.model.LayoutElementData;
import ru.teachbase.manage.layout.model.LayoutChangeData;
import ru.teachbase.manage.modules.model.ModuleInstanceData;
import ru.teachbase.manage.session.model.MeetingUpdateData;
import ru.teachbase.manage.session.model.UserChangeData;
import ru.teachbase.manage.streams.model.StreamData;
import ru.teachbase.manage.streams.model.StreamMapData;
import ru.teachbase.model.App;
import ru.teachbase.model.User;
import ru.teachbase.module.chat.model.ChatMessage;
import ru.teachbase.module.documents.model.DocumentData;
import ru.teachbase.module.documents.model.FileItem;
import ru.teachbase.module.documents.model.WorkplaceData;
import ru.teachbase.utils.shortcuts.config;
import ru.teachbase.utils.shortcuts.error;

/**
 *
 * Class that implements RTMPManager methods but works without real RTMP connection.
 *
 * It works with recording files and imitates server behaviour.
 *
 */

public class RTMPPretender extends RTMPManager {

    private var _player:RecordingPlayer;

    //---------- private ----------//

    public function RTMPPretender(register:Boolean = false) {
        super(register);


        //---- register all aliases ----//

        new WorkplaceData();
        new DocumentData();
        new FileItem();
        new UserChangeData();
        new MeetingUpdateData();
        new User();
        new ModuleInstanceData();
        new LayoutChangeData();
        new LayoutElementData();
        new ChatMessage();
        new BoardUpdateData();
        new StyleData();


    }


    override protected function initialize(reinit:Boolean = false):void{

        if(reinit){
            _initialized = true;
            return;
        }

        var _root_url:String = config("recording/url");

        if(!_root_url){

            error("Recording URL undefined");
            _failed = true;
            return;

        }

        _player = new RecordingPlayer(this);

        _player.addEventListener(ErrorEvent.ERROR, playerError);
        _player.addEventListener(Event.COMPLETE, playerReady);

        _player.init(_root_url);
    }


    protected function playerReady(e:Event):void{
        _initialized = true;
        _player.removeEventListener(Event.COMPLETE,playerReady);
    }


    protected function playerError(e:ErrorEvent):void{
        if(!initialized) _failed = true;
    }


    override public function callServer(method:*, responder:IResponder, ...rest):void{

        if(method == "tb_login" || method == "tb_login_by_sid"){

            //todo: check authorization

            const user:User = new User();

            user.sid = user.id = user.suffix = 0;
            user.name = user.email = user.fullName = user.guest_id = "";

            responder && responder.result(["",user]);

        }


        if(method =="send_method"){

            if(rest.length>4 && rest[1] == "get_history"){

                const type:String = rest[2];

                var match:Array;

                var data:*;

                // workplace history can be represented as document

                if(match = type.match(/workplace::(\d+)/)){

                    const instance_id:int = int(match[1]);

                    for each(var _doc:DocumentData in App.meeting.docsById){
                        if(_doc.instance_id == instance_id)
                            data = new WorkplaceData({type:"active",data:_doc});
                    }
                }else
                    data = _player.getHistory(type);


                responder && responder.result(data);

            }
        }


    }

    public function get player():RecordingPlayer {
        return _player;
    }
}
}
