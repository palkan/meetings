/**
 * User: palkan
 * Date: 5/31/13
 * Time: 2:15 PM
 */
package ru.teachbase.manage.rtmp.events {
import flash.events.Event;

import ru.teachbase.manage.rtmp.model.Packet;

public class RTMPEvent extends Event {

    public static const DATA:String = "rtmp_data";

    private var _packet:Packet;

    public function RTMPEvent(type:String, packet:Packet, bubbles:Boolean = false, cancelable:Boolean = false) {
        super(type, bubbles, cancelable);
        _packet = packet;
    }

    override public function clone():Event{
        return new RTMPEvent(type,packet,bubbles,cancelable);
    }

    public function get packet():Packet {
        return _packet;
    }

    public function set packet(value:Packet):void {
        _packet = value;
    }
}
}
