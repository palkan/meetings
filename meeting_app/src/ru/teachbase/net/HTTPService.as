package ru.teachbase.net
{
import flash.events.ErrorEvent;
import flash.events.Event;
import flash.events.HTTPStatusEvent;
import flash.events.IOErrorEvent;
import flash.net.URLLoader;
import flash.net.URLRequest;
import flash.net.URLRequestMethod;
import flash.net.URLVariables;

import mx.rpc.Responder;

import ru.teachbase.model.App;
import ru.teachbase.utils.Strings;
import ru.teachbase.utils.shortcuts.config;

/**
	 * 
	 * @author VOVA
	 * 
	 */	
	public class HTTPService
	{
		public static const DOMAIN:String = config('service::http');
		public static const ROOT_PATH:String = DOMAIN+"/bitrix/components/newebils/webinar.show/";
		
		public static const UPLOAD_URL:String = ROOT_PATH+"upload.php";
	
		private const URLS:Object = {
			auth:			ROOT_PATH+"auth.php",
			folders:		ROOT_PATH+"folders.php",
			files:			ROOT_PATH+"files.php",
			convert:		ROOT_PATH+"convert.php",
			login:			ROOT_PATH+"login.php",
			save_image:		ROOT_PATH+"save_image.php",
			meetings:		ROOT_PATH+"list.php",
			post_upload:	ROOT_PATH+"post_upload.php",
			test:			ROOT_PATH+"test.php"
		}
		
		
		private static var _token:String;
		
		/**
		 * Create new HTTP service.
		 *  
		 * @param token seckret key to authenticate requests. Temporary not in use.
		 * 
		 */		
		
		public function HTTPService(token:String = "")
		{
			_token = token;
		}
		
		/**
		 * 
		 * Make request to server.
		 * 
		 * @param action 
		 * @responder if request is successful <i>result</i> handler is applied with recieved data json decoded (if it's possible) as argument
		 * @param params Object with additional params
		 * 
		 */		
		public function request(action:String, responder:Responder = null, params:Object = null):void{
			
			if(!URLS[action]){
				loadError(new ErrorEvent(ErrorEvent.ERROR, false, false, "Undefined action"));
				return;
			}
			
			
			
			var _urlLoader:URLLoader = new URLLoader();
			
			_urlLoader.addEventListener(Event.COMPLETE, urlLoadComplete);
			_urlLoader.addEventListener(IOErrorEvent.IO_ERROR, ioError);
			_urlLoader.addEventListener(HTTPStatusEvent.HTTP_STATUS, loadStatus);
			
			
			function urlLoadComplete(event:Event):void{
				responder && responder.result(Strings.json_decode(String(_urlLoader.data)));
			}
			
			function ioError(event:ErrorEvent):void{
			}
			
			function loadError(event:ErrorEvent):void{
				responder && responder.fault(event.text);
			}
			
			
			function onAuthComplete(data:Object):void{
				
				request(action,responder,params);
				
			}
			
			function loadStatus(event:HTTPStatusEvent):void{
				switch (event.status) {
					case 400:
						loadError(new ErrorEvent(ErrorEvent.ERROR, false, false, "HTTP Status 400; Bad request."));
						break;
					case 401:{
						if(action!="auth" && action!="login"){
							request("auth",new Responder(onAuthComplete,responder.fault),{token:_token});
						}else
							loadError(new ErrorEvent(ErrorEvent.ERROR, false, false, "Authorization failed."));
						break;
					}
					case 403:
						loadError(new ErrorEvent(ErrorEvent.ERROR, false, false, "HTTP Status 403; Forbidden."));
						break;
					case 404:
						loadError(new ErrorEvent(ErrorEvent.ERROR, false, false, "HTTP Status 404; Not Found."));
						break;
					case 500:
						loadError(new ErrorEvent(ErrorEvent.ERROR, false, false, "HTTP Status 500; Internal Server Error."));
						break;
					case 503:
						loadError(new ErrorEvent(ErrorEvent.ERROR, false, false, "HTTP Status 503; Service Unavailable."));
						break;
				}
			}
			
			
			var _req:URLRequest = new URLRequest(URLS[action]);
			_req.method = URLRequestMethod.POST;
			_req.data = generateVars(params);
			_urlLoader.load(_req);
			
		}
		
		
		public static function generateVars(params:Object = null):URLVariables{
			
			var _vars:URLVariables = new URLVariables();
			_vars.mid = App.meeting.id;
			_vars.uid = (App.user) ? App.user.id : 0;
			_vars.token = _token;
			
			
			if(params){
				for (var key:String in params)
					_vars[key] = params[key];
			}
			
			return _vars;
			
		}
		
	}
}