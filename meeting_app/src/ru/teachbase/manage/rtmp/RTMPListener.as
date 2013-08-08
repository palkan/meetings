package ru.teachbase.manage.rtmp {
import flash.events.EventDispatcher;

import ru.teachbase.manage.rtmp.events.RTMPEvent;
import ru.teachbase.manage.rtmp.model.Packet;

[Event(type="ru.teachbase.manage.rtmp.events.RTMPEvent", name="rtmp_data")]
public class RTMPListener extends EventDispatcher {
    private var _type:String;
    private var _initialized:Boolean;

    private const _messagesToSend:Vector.<Packet> = new Vector.<Packet>();
    protected var _readyToReceive:Boolean = false;

    private var _lastMessageId:Number = 0;

    //------------ constructor ------------//

    public function RTMPListener(type:String, initialize:Boolean = false) {
        _type = type;
        initialize && this.initialize();
    }

    //------------ initialize ------------//

    public function initialize(...rest):void {
        if (_initialized) return;

        RTMPManager.listen(_type, inputHandler);

        _initialized = true;
    }

    public function dispose():void {
        RTMPManager.unlisten(_type, inputHandler);
        _messagesToSend.length = 0;
        _readyToReceive = false;
        _initialized = false;
    }

    //--------------- ctrl ---------------//

    protected function dispatchData(packet:Packet):void {
        _lastMessageId = packet.id;
        dispatchEvent(new RTMPEvent(RTMPEvent.DATA, packet));
    }

    //------- handlers / callbacks -------//

    private final function inputHandler(packet:Packet):void {
        _readyToReceive && dispatchData(packet);
        !_readyToReceive && _messagesToSend.push(packet);
    }

    //--------- get/set -----------//


    public function get type():String {
        return _type;
    }

    public function get initialized():Boolean {
        return _initialized;
    }

    public function set readyToReceive(value:Boolean):void {
        if (_readyToReceive == value)
            return;

        _readyToReceive = value;

        if(!value) return;

        for each (var _d:Packet in _messagesToSend)
            dispatchData(_d);

        _messagesToSend.length = 0;
    }


    public function get lastMessageId():Number {
        return _lastMessageId;
    }
}
}