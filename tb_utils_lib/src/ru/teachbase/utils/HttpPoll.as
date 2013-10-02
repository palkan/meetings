/**
 * User: palkan
 * Date: 10/1/13
 * Time: 11:50 AM
 */
package ru.teachbase.utils {
import flash.events.ErrorEvent;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.HTTPStatusEvent;
import flash.events.IOErrorEvent;
import flash.net.URLLoader;
import flash.net.URLRequest;
import flash.net.URLRequestMethod;
import flash.net.URLVariables;

import mx.rpc.Responder;

import ru.teachbase.utils.shortcuts.debug;


/**
 * Class for working with HTTP long polling.
 *
 * Web server MUST respond with 204 status code if request must be restarted (i.e. no information available for now).
 *
 */

public class HttpPoll extends EventDispatcher {

    private var _url:String;
    private var _method:String;
    private var _vars:URLVariables;

    private var _responder:Responder;

    private var _loader:URLLoader;

    private var _loading:Boolean = false;

    private var _restarting:Boolean = false;

    /**
     *
     * @param url
     * @param responder
     * @param method
     * @param vars
     */

    public function HttpPoll(url:String, responder:Responder = null, method:String = URLRequestMethod.POST, vars:URLVariables = null) {
        super();

        _url = url;
        _method = method;
        _vars = vars;
        _responder = responder;

        _loader = new URLLoader();

    }

    /**
     *
     * Start polling
     *
     * @param restart Is <code>true</code> if we restarting the same request (so we don't need to setup listeners again)
     */

    public function poll(restart:Boolean = false):void {
        const req:URLRequest = new URLRequest(_url);
        req.method = _method;
        _vars && (req.data = _vars);
        !restart && addListeners();
        _loading = true;
        _loader.load(req);
    }


    /**
     * Cancel polling
     */

    public function cancel():void{
        removeListeners();
        _loading && _loader.close();
        _loading = false;
    }


    private function addListeners():void {
        _loader.addEventListener(Event.COMPLETE, urlLoadComplete);
        _loader.addEventListener(IOErrorEvent.IO_ERROR, ioError);
        _loader.addEventListener(HTTPStatusEvent.HTTP_STATUS, loadStatus);
    }

    private function removeListeners():void {
        _loader.removeEventListener(Event.COMPLETE, urlLoadComplete);
        _loader.removeEventListener(IOErrorEvent.IO_ERROR, ioError);
        _loader.removeEventListener(HTTPStatusEvent.HTTP_STATUS, loadStatus);
    }

    private function urlLoadComplete(e:Event):void {
        if(_restarting) return;
        removeListeners();
        _loading = false;
        _responder && _responder.result(_loader.data);
    }

    private function ioError(e:ErrorEvent):void {
        __sendError(e.text);

    }

    private function __sendError(message:String):void {
        removeListeners();
        _loading = false;
        _responder && _responder.fault(message);
    }


    private function loadStatus(event:HTTPStatusEvent):void {
        debug(event.status);
        _restarting = false;
        switch (event.status) {
            case 204:
                _restarting = true;
                _loading = false;
                poll(true);
                break;
            case 400:
                __sendError("HTTP Status 400; Bad request.");
                break;
            case 401:
                __sendError("Authorization failed.");
                break;
            case 403:
                __sendError("HTTP Status 403; Forbidden.");
                break;
            case 404:
                __sendError("HTTP Status 404; Not Found.");
                break;
            case 500:
                __sendError("HTTP Status 500; Internal Server Error.");
                break;
            case 503:
                __sendError("HTTP Status 503; Service Unavailable.");
                break;
        }
    }

    public function get loading():Boolean {
        return _loading;
    }
}

}
