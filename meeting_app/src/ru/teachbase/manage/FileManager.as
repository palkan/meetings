package ru.teachbase.manage
{
import flash.events.DataEvent;
import flash.events.ErrorEvent;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.ProgressEvent;
import flash.net.FileReference;

import ru.teachbase.events.FileStatusEvent;
import ru.teachbase.module.documents.model.FileItem;

[Event(name="start", type="ru.teachbase.events.FileStatusEvent")]
	[Event(name="cancel", type="ru.teachbase.events.FileStatusEvent")]
	[Event(name="progress", type="flash.events.ProgressEvent")]
	[Event(name="complete", type="flash.events.Event")]
	[Event(name="error", type="flash.events.ErrorEvent")]
	
	public class FileManager extends Manager
	{
		
		private var file:FileReference;
		
		private var _busy:Boolean = false;
		
		//private var trait:FileTrait = TraitManager.instance.createTrait(FileTrait) as FileTrait;;
		
		private var _item:FileItem;
		
		private var _filename:String;
		
		public var xml_url:String;
		
		
		public function FileManager()
		{
			super();
		}
		
		
		override protected function initialize():void
		{
			
			_initialized = true;
			/*trait.addEventListener(Event.COMPLETE,conversionCompleteHandler);
			trait.addEventListener(FileStatusEvent.START, startHandler);
			trait.addEventListener(FileStatusEvent.PROGRESS, conversionProgressHandler);
			trait.addEventListener(ErrorEvent.ERROR, errorHandler);          */
		}
		
		protected function conversionCompleteHandler(event:Event):void
		{
			dispatcher.dispatchEvent(new FileStatusEvent(FileStatusEvent.COMPLETE,xml_url));
			_busy = false;
		}		
		
		/**
		 * Call system file chooser, upload file to the server and wait for response. 
		 * 
		 */
		public function upload_convert():void{
			
			if(_busy)
				return;
			
			file = new FileReference();
			file.addEventListener(Event.SELECT, selectHandler);
			file.addEventListener(Event.CANCEL,cancelHandler);
			_busy = true;
			file.browse();
			
		}
		
		
		/**
		 * Upload dropped file.
		 * 
		 */
		
		public function upload_file(_file:FileReference):void{
			
			file = _file;
			_busy = true;
			
			selectHandler();
			
		}
		
		
		/**
		 * Send request to the server to convert document and receive doc xml or error.
		 *  
		 * @param _item FileItem assigned to document in library
		 * 
		 */
		public function convert(item:FileItem):void{
			/*if(!App.service.http)
				return;
			
			
			_filename = item.title;
			_item = item;
			App.service.http.request("convert",new Responder(success, failure),{fid:item.id});
			                                                                      */
		}
		
		
		/**
		 * Send request to the server to upload image from external server to the library.
		 *  
		 * @param _item FileItem assigned to image
		 * 
		 */
		
		
		public function grabImage(item:FileItem):void{
		/*	if(!App.service.http)
				return;
			
			_filename = item.title;
			_item = item;
			App.service.http.request("save_image",new Responder(success, failure),{url:item.url});
			*/
		}
		
		
		private function success(obj:Object):void{
			parseServerResponse(obj);
		}
		
		private function failure(reason:String):void{
			_item = null;
			dispatcher.dispatchEvent(new ErrorEvent(ErrorEvent.ERROR,false,false,reason));
		}
		
		
		protected function cancelHandler(event:Event):void
		{
			_busy = false;
			file.removeEventListener(Event.SELECT, selectHandler);
			file.removeEventListener(Event.CANCEL,cancelHandler);
			dispatcher.dispatchEvent(new FileStatusEvent(FileStatusEvent.CANCEL));
		}
		
		
		
		private function selectHandler(event:Event = null):void 
		{
			
		/*	event && file.removeEventListener(Event.SELECT, selectHandler);
			event && file.removeEventListener(Event.CANCEL,cancelHandler);
			
			if(!App.service.http)
				return;
			
			_filename = file.name;
			
			dispatcher.dispatchEvent(new FileStatusEvent(FileStatusEvent.SELECTED));
				
			file.addEventListener(IOErrorEvent.IO_ERROR,ioErrorHandler);
			file.addEventListener(ProgressEvent.PROGRESS,progressHandler);
			file.addEventListener(Event.COMPLETE,completeHandler);
			file.addEventListener(DataEvent.UPLOAD_COMPLETE_DATA,dataHandler);
				
			var req:URLRequest = new URLRequest(HTTPService.UPLOAD_URL);
			var vars:URLVariables = HTTPService.generateVars();
			req.data = vars;
								
			file.upload(req);         */
			
		}
		
		private function dataHandler(event:DataEvent):void{
			
		/*	file.removeEventListener(IOErrorEvent.IO_ERROR,ioErrorHandler);
			file.removeEventListener(ProgressEvent.PROGRESS,progressHandler);
			file.removeEventListener(DataEvent.UPLOAD_COMPLETE_DATA,dataHandler);
			
			try{
				var obj:Object = JSON.parse(event.data);
				
				if(obj.status === 'ok' && obj.fid>0)
					App.service.http.request("post_upload",new Responder(success,failure),{fid:obj.fid});
				else
					dispatcher.dispatchEvent(new ErrorEvent(ErrorEvent.ERROR,false,false,"Failed to upload document to library"));
				
			}catch(e:Error){
				dispatcher.dispatchEvent(new ErrorEvent(ErrorEvent.ERROR,false,false,"Failed to upload document to library. Unknown error"));	
			}
			
			_busy = false;  */

		}
		
	
		
		
		private function ioErrorHandler(event:IOErrorEvent):void {
			file.removeEventListener(IOErrorEvent.IO_ERROR,ioErrorHandler);
			file.removeEventListener(ProgressEvent.PROGRESS,progressHandler);
			file.removeEventListener(DataEvent.UPLOAD_COMPLETE_DATA,dataHandler);
			
			dispatcher.dispatchEvent(new ErrorEvent(ErrorEvent.ERROR,false,false,event.text));
			_busy = false;
		}
		
		protected function errorHandler(event:ErrorEvent):void
		{
			dispatcher.dispatchEvent(new ErrorEvent(ErrorEvent.ERROR,false,false,event.text));
			_busy = false;
		}	
		
		private function progressHandler(event:ProgressEvent):void {
			
			var progress:int = Math.round((event.bytesLoaded / event.bytesTotal) * 25);
			
			dispatcher.dispatchEvent(new FileStatusEvent(FileStatusEvent.PROGRESS,progress));
			
		}
		
		protected function conversionProgressHandler(event:FileStatusEvent):void
		{
			var progress:int = event.value;
			
			dispatcher.dispatchEvent(new FileStatusEvent(FileStatusEvent.PROGRESS,progress));
		}		
		
		
		
		private function completeHandler(event:Event):void {
			file.removeEventListener(Event.COMPLETE,completeHandler);
		}
		
		
		protected function startHandler(event:FileStatusEvent):void
		{
			
		}	
		
		public function addEventListener(type:String, handler:Function):void{
			dispatcher.addEventListener(type,handler);
		}
		
		public function removeEventListener(type:String, handler:Function):void{
			dispatcher.removeEventListener(type,handler);
		}
		
		
		private function parseServerResponse(obj:Object):void{
			
			if(obj.status === "ok"){
				if(!obj.type || obj.type == "undefined")
					dispatcher.dispatchEvent(new ErrorEvent(ErrorEvent.ERROR,false,false,"Incompatible document format"));
				else
					dispatcher.dispatchEvent(new FileStatusEvent(FileStatusEvent.COMPLETE,obj));			
			}else if(obj.status === "error"){
				dispatcher.dispatchEvent(new ErrorEvent(ErrorEvent.ERROR,false,false,obj.message));
			}else
				dispatcher.dispatchEvent(new ErrorEvent(ErrorEvent.ERROR,false,false,"Failed to upload document to library. Unknown error"));
			
		}
		
		public function get filename():String{
			
			return _filename;
			
		}

		public function get item():FileItem
		{
			return _item;
		}
		
		override public function dispose():void{
			_initialized = false;
		}

		
	}
}