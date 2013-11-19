/**
 * User: palkan
 * Date: 10/17/13
 * Time: 11:24 AM
 */
package ru.teachbase.manage.streams {
import com.mangui.HLS.HLS;

import flash.net.NetStream;
import flash.utils.Dictionary;
import flash.utils.clearInterval;
import flash.utils.setInterval;

import ru.teachbase.events.ChangeEvent;
import ru.teachbase.events.GlobalEvent;

import ru.teachbase.manage.streams.model.NetStreamClient;
import ru.teachbase.model.App;
import ru.teachbase.model.User;
import ru.teachbase.utils.Permissions;

public class RecordStreamManager extends StreamManager {

    private const streamsByUserId:Dictionary = new Dictionary(true);

    private const _to_start_ns:Vector.<NetStream> = new <NetStream>[];

    public function RecordStreamManager(registered:Boolean = false) {
        super(registered);
    }

    override protected function initialize(reinit:Boolean = false):void {

        _model = App.meeting;
        _initialized = true;


        GlobalEvent.addEventListener(GlobalEvent.USER_JOIN, handleUserLeave);

        var _id:uint = setInterval(function():void{
            if(!App.session || !App.session.initialized) return;

            clearInterval(_id);

            usersHandler();
        }, 100);
    }

    override public function clear():void{
        _initialized = false;
        _failed = false;
        _started = false;
    }


    override public function loadStreams():void{
        while(_to_start_ns.length){
            const ns:NetStream = _to_start_ns.pop();
            bindUserStream(ns);
            _model.streamList.addItem(ns);
        }
        _started = true;
    }

    public function addHLSStream(ns:NetStream):void {

        bindUserStream(ns);

        _model.streamsByName[(ns.client as NetStreamClient).data.name] = ns;

        _started && _model.streamList.addItem(ns);
        !_started && _to_start_ns.push(ns);

    }




    public function removeHLSStream(hls:HLS):void {

        if (!hls) return;

        var ns:NetStream = hls.stream;

        delete _model.streamsByName[(ns.client as NetStreamClient).data.name];

        const ind:int = _model.streamList.source.indexOf(ns);

        (ind > -1) && _model.streamList.removeItemAt(ind);
    }


    public function removeHLSStreams():void {
        for each(var ns:NetStream in _model.streamList)
            delete _model.streamsByName[(ns.client as NetStreamClient).data.name];

        _model.streamList.removeAll();
    }


    protected function bindUserStream(ns:NetStream):void{

        var client:NetStreamClient = ns.client as NetStreamClient;

        if(!client || client.data.type != "media" || !_model.usersByID[client.data.user_id]) return;

        var user:User = _model.usersByID[client.data.user_id];

        client.onAudioVideoStatus({hasVideo: Permissions.camAvailable(user.shareStatus), hasAudio:Permissions.micAvailable(user.shareStatus)});

        streamsByUserId[user] = client;

        user.addEventListener(ChangeEvent.CHANGED, userChangeHandler);

    }


    protected function handleUserLeave(e:GlobalEvent):void{

        if(streamsByUserId[e.value]){

            (e.value as User).removeEventListener(ChangeEvent.CHANGED, userChangeHandler);
            delete streamsByUserId[e.value];

        }

    }

    protected function usersHandler():void{

        for each(var ns:NetStream in _model.streamList){

            bindUserStream(ns);

        }

    }


    protected function userChangeHandler(e:ChangeEvent):void{

        if(e.property == "shareStatus"){

            const user:User = e.target as User;

            if(!streamsByUserId[user]) return;

            const client:NetStreamClient = streamsByUserId[user] as NetStreamClient;

            client.onAudioVideoStatus({hasVideo: Permissions.camAvailable(user.shareStatus), hasAudio:Permissions.micAvailable(user.shareStatus)});

        }

    }


}
}
