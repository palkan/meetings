/**
 * User: palkan
 * Date: 5/31/13
 * Time: 2:06 PM
 */
package ru.teachbase.utils.shortcuts {
import mx.rpc.IResponder;

import ru.teachbase.manage.rtmp.model.Packet;

import ru.teachbase.manage.rtmp.model.Recipients;
import ru.teachbase.model.App;

/**
 * Send Packet to server
 *
 * @param data
 * @param recipient Number|Array
 * @param responder
 * @param system  System messages are stored for history; default <code>true</code>
 */

public function rtmp_send(type:String, data:*, recipient:* = Recipients.ALL, responder:IResponder = null, system:Boolean = true):void
{
    var packet:Packet = new Packet(type,data,recipient,system);

    App.rtmp.callServer("send_message",responder,App.user.rtmpToken,packet);
}

}
