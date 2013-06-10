/**
 * User: palkan
 * Date: 5/31/13
 * Time: 2:07 PM
 */
package ru.teachbase.utils.shortcuts {
import mx.rpc.IResponder;

import ru.teachbase.model.App;

/**
 * Call server method
 *
 * @param method - method name
 * @param responder
 * @param data - any arguments
 *
 */
public function rtmp_call(method:String, responder:IResponder = null, ...data:Array):void
{
    data.unshift("send_method", responder, App.user.rtmpToken, method);

    App.rtmp.callServer.apply(null,data);
}
}
