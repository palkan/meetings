package ru.teachbase.manage.file {
import flash.events.DataEvent;
import flash.events.ErrorEvent;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.HTTPStatusEvent;
import flash.events.IOErrorEvent;
import flash.events.ProgressEvent;
import flash.net.FileReference;
import flash.net.URLRequest;
import flash.net.URLRequestMethod;
import flash.net.URLVariables;

import mx.rpc.Responder;

import ru.teachbase.events.FileStatusEvent;
import ru.teachbase.manage.file.model.FileProcessData;
import ru.teachbase.model.App;
import ru.teachbase.module.documents.model.FileItem;
import ru.teachbase.utils.HttpPoll;
import ru.teachbase.utils.shortcuts.$null;
import ru.teachbase.utils.shortcuts.rtmp_call;
import ru.teachbase.utils.shortcuts.warning;

[Event(name="tb:fs:start", type="ru.teachbase.events.FileStatusEvent")]
[Event(name="tb:fs:cancel", type="ru.teachbase.events.FileStatusEvent")]
[Event(name="tb:fs:progress", type="ru.teachbase.events.FileStatusEvent")]
[Event(name="tb:fs:complete", type="ru.teachbase.events.FileStatusEvent")]
[Event(name="error", type="flash.events.ErrorEvent")]
[Event(name="tb:fs:processing", type="ru.teachbase.events.FileStatusEvent")]
[Event(name="tb:fs:processing_complete", type="ru.teachbase.events.FileStatusEvent")]


/**
 *
 * Handle files upload and processing.
 *
 */


public class FileManager extends EventDispatcher {

    private var _file:FileReference;

    private var _busy:Boolean = false;

    private var _item:FileItem;

    private var _filename:String;

    private var _uploadInfo:Object;
    private var _waitUploadInfo:Boolean = false;

    private var _poller:HttpPoll;

    public function FileManager() {
        new FileProcessData();
    }

    /**
     * Call system file chooser, upload file to the server and wait for response.
     *
     */
    public function upload():void {

        if (_busy) return;

        _uploadInfo = null;

        generateUploadInfo();

        _file = new FileReference();
        _file.addEventListener(Event.SELECT, selectHandler);
        _file.addEventListener(Event.CANCEL, cancelHandler);

        _busy = true;
        _file.browse();

    }

    /**
     *
     * Abort uploading process.
     *
     */


    public function abort():void {

        _poller && _poller.loading && _poller.cancel();
        _poller = null;

        if (!_busy || !_file) return;

        _file.cancel();
        _file = null;
        _busy = false;
    }


    /**
     * Upload dropped file.
     *
     */

    public function upload_file(_file:FileReference):void {
        _file = _file;
        _file.cancel()
        _busy = true;
        selectHandler();
    }


    /**
     * Send request to the server to upload image from external server to the library.
     *
     * @param _item FileItem assigned to image
     *
     */


    public function grabImage(item:FileItem):void {
        /*	if(!App.service.http)
         return;

         _filename = item.title;
         _item = item;
         App.service.http.request("save_image",new Responder(success, failure),{url:item.url});
         */
    }


    protected function cancelHandler(event:Event):void {
        _busy = false;
        _file.removeEventListener(Event.SELECT, selectHandler);
        _file.removeEventListener(Event.CANCEL, cancelHandler);
        dispatchEvent(new FileStatusEvent(FileStatusEvent.CANCEL));
    }


    private function selectHandler(event:Event = null):void {

        event && _file.removeEventListener(Event.SELECT, selectHandler);
        event && _file.removeEventListener(Event.CANCEL, cancelHandler);

        _filename = _file.name;
        dispatchEvent(new FileStatusEvent(FileStatusEvent.SELECTED));

        if (_uploadInfo) doUpload();
        else _waitUploadInfo = true;

    }


    private function dataHandler(event:DataEvent):void {

        removeFileListeners();

        var obj:Object = JSON.parse(event.data);

        if (obj.conversion_status === 'converting') {
            dispatchEvent(new FileStatusEvent(FileStatusEvent.PROCESSING, obj.conversion_id));

            if (_uploadInfo.polling_url) {

                const vars:URLVariables = new URLVariables();
                vars.id=obj.conversion_id;

                _poller = new HttpPoll(_uploadInfo.polling_url, new Responder(pollComplete, pollFailed),URLRequestMethod.GET,vars);
                _poller.poll();
            } else
                warning('Polling url is undefined');

        } else {
            // It should be impossible)
            _sendError('Unknown error');
        }
        _busy = false;

    }


    private function ioErrorHandler(event:IOErrorEvent):void {
        removeFileListeners();
        _sendError(event.text);
    }

    private function httpHandler(event:HTTPStatusEvent):void {
        if(event.status > 400){
            removeFileListeners();
            _sendError("Error: #"+ event.status);
        }
    }

    private function progressHandler(event:ProgressEvent):void {

        var progress:int = Math.round((event.bytesLoaded / event.bytesTotal) * 100);

        dispatchEvent(new FileStatusEvent(FileStatusEvent.PROGRESS, progress));

    }


    private function pollComplete(json:String):void {

        const data:Object = JSON.parse(json);

        dispatchEvent(new FileStatusEvent(FileStatusEvent.PROCESSING_COMPLETE, data));
        _busy = false;

    }


    private function pollFailed(error:String):void {

        _sendError(error);
    }


    private function doUpload() {

        if (!_uploadInfo) return;

        if (_uploadInfo.status != "ok") {
            _sendError(_uploadInfo.message);
            return;
        }

        addFileListeners();

        var req:URLRequest = new URLRequest(_uploadInfo.url);

        var vars:URLVariables = new URLVariables();
        vars.token = _uploadInfo.token;
        vars.meeting_id = App.meeting.id;
        vars.session_id = App.user.sid;

        req.data = vars;

        _file.upload(req,'source');
    }


    /**
     * Send rtmp request to get secret token and upload URL
     */

    private function generateUploadInfo() {

        rtmp_call("file_upload_info", new Responder(success, $null));

        function success(data:Object):void {
            _uploadInfo = data;
            if (_waitUploadInfo) {
                _waitUploadInfo = false;
                doUpload();
            }
        }

    }

    private function addFileListeners():void {
        _file.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
        _file.addEventListener(HTTPStatusEvent.HTTP_STATUS, httpHandler);
        _file.addEventListener(ProgressEvent.PROGRESS, progressHandler);
        _file.addEventListener(DataEvent.UPLOAD_COMPLETE_DATA, dataHandler);
    }

    private function removeFileListeners():void {
        _file.removeEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
        _file.removeEventListener(HTTPStatusEvent.HTTP_STATUS, httpHandler);
        _file.removeEventListener(ProgressEvent.PROGRESS, progressHandler);
        _file.removeEventListener(DataEvent.UPLOAD_COMPLETE_DATA, dataHandler);
    }


    private function _sendError(msg:String):void {
        _busy = false;
        dispatchEvent(new ErrorEvent(ErrorEvent.ERROR, false, false, msg));
    }


    public function get filename():String {

        return _filename;

    }

    public function get item():FileItem {
        return _item;
    }

}
}