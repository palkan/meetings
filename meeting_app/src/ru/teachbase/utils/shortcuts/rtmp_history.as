/**
 * User: palkan
 * Date: 5/31/13
 * Time: 2:07 PM
 */
package ru.teachbase.utils.shortcuts {
import mx.rpc.IResponder;

import ru.teachbase.model.App;

/**
 * Get history from server
 *
 * @param type - history id
 * @param responder
 * @param lastMessageID - receive only messages with <code>id</code> greater than <code>lastMessageID</code>
 * @param args additional arguments as array
 *
 */
public function rtmp_history(type:String, responder:IResponder = null, lastMessageID:Number = 0, args:Array = null):void
{
    App.rtmp.callServer("send_method", responder, App.user.rtmpToken, "get_history", type, lastMessageID, args);
}
}
