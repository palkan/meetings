package ru.teachbase.utils.extensions
{
import flash.display.Loader;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.net.FileReference;
import flash.net.URLRequest;
import flash.system.ApplicationDomain;
import flash.system.LoaderContext;

import ru.teachbase.utils.BrowserUtils;
import ru.teachbase.utils.Strings;
import ru.teachbase.utils.shortcuts.debug;
import ru.teachbase.utils.system.getPlayerVersion;

/**
	 *@eventType flash.events.Event.COMPLETE 
	 */
	[Event(name="complete", type="flash.events.Event")]
	
	/**
	 * Adapter to work with Adobe airSWF object 
	 *  
	 * 
	 * @author Teachbase
	 * @see http://help.adobe.com/en_US/air/build/WS5b3ccc516d4fbf351e63e3d118666ade46-7fcb.html
	 * 
	 */
	public class AIRLauncher extends EventDispatcher
	{
		public static const AIR_AVAILABLE:uint = 1 << 1;
		public static const AIR_INSTALLED:uint = 1 << 2;
		public static const APP_INSTALLED:uint = 1 << 3;
		public static const IN_CHROME:uint = 1 << 4;
		
		
		public static const APP_URL:String = "http://airdownload.adobe.com/air/browserapi/air.swf";
		
		private var appID:String;
		private var publisherID:String;
		private var launcherArgs:Array;
		private var url:String;
		private var runtime:String;
		
		private var airSWF:Object;
		
		private var _status:uint = 0;
			
		private var _initialized:Boolean = false;
		
		
		/**
		 *  Creates new AIRLauncher for application by appId, pubId and launch params.
		 *  
		 * @param _appID Application ID
		 * @param _pubID Publisher ID
		 * @param params Launch arguments
		 * @param _url URL of air file to install
		 * @param _runtime AIR runtime version requiered
		 * 
		 */
		public function AIRLauncher(_appID:String,_pubID:String = '', params:Array = null, _url:String = null, _runtime:String = "3.1")
		{
			appID = _appID;
			publisherID = _pubID;
			launcherArgs = params;
			runtime = _runtime;
			url = _url;
						
			super(null);

		}
		
		
		
		/**
		 *  Initialize airSWF object
		 * 
		 */
		public function init():void{
			if(_initialized) return;
			createSWFObject();
		}
		
		
		
		/**
		 * Install air application. <br/.
		 * 
		 * If application packaged not as *.air file than download the installer. 
		 * 
		 * 
		 */
		public function installApp():void{
			
			if(!(_status & AIR_INSTALLED) || !_initialized || !url) return;
			
			if(Strings.extension(url) === 'air'){
				airSWF.installApplication(url, runtime, launcherArgs);
			}else{
				loadApplicationAsFile();
			}
			
		}
		
		
		private function loadApplicationAsFile():void{
			
			var file:FileReference = new FileReference();
			
			file.download(new URLRequest(url));
			
		}
		
		
		public function launchApp():void{
			
			if(!(_status & APP_INSTALLED) || !_initialized) return;
			
			airSWF.launchApplication(appID, publisherID, launcherArgs);
			
		}
		
		
		
		private function createSWFObject():void{
		
			var airSWFLoader:Loader = new Loader(); 
			var loaderContext:LoaderContext = new LoaderContext();  
				loaderContext.applicationDomain = ApplicationDomain.currentDomain; 
				
				airSWFLoader.contentLoaderInfo.addEventListener(Event.INIT, onInit); 
				airSWFLoader.load(new URLRequest(APP_URL), loaderContext); 
		
				function onInit(e:Event):void
				{
					airSWF = e.target.content;
					var status_str:String = airSWF.getStatus();
					debug(status_str,'launcher_status');
					switch(status_str){
						case 'installed':
						//	Logger.log('installed','launcher');
							_status+=AIR_INSTALLED;
							break;
						case 'available':
						//	Logger.log('available','launcher');
							checkChromeHack();
							break;
						default:
							break;
					}
					
					if(_status & AIR_INSTALLED)
						checkVersion();
					else
						complete();
						
					
				}
		}
		
		
		/**
		 * We have to check whether application is running in Chrome browser >v21 and FP v11.5<  
		 * 
		 */
		public function checkChromeHack():void{
			
			var info:Object = BrowserUtils.getVersion();
			
			if(!info){
				_status+=AIR_AVAILABLE;
				return;
			}
			
			
			debug(info.userAgent,'launcher');
			
			
			if((info.userAgent as String).toLowerCase().indexOf("chrome")>0){
				
				var ver:Object = getPlayerVersion();
				
				if(!(ver.major >= 11 && ver.minor >= 6)){
					_status+=IN_CHROME;
					return;
				}
			}
			
			_status+=AIR_AVAILABLE;
		}
		
		
		private function complete():void{
			_initialized = true;
			dispatchEvent(new Event(Event.COMPLETE));
		}
		
		
		private function checkVersion():void{
			
			airSWF.getApplicationVersion(appID, publisherID, versionDetectCallback);
			
			function versionDetectCallback(version:String):void 
			{ 
				if (version == null) 
				{ 
					
				} 
				else 
				{ 
					_status+=APP_INSTALLED;
				}
				
				complete();
			}
			
			
		}

		/**
		 * Status of AIR application represented as bit mask generated from values:
		 * 
		 * <table>
		 * 		<tr>
		 * 			<td>Const</td><td>Description</td>
		 * 			<td>AIR_AVAILABLE</td><td>AIR environment can be installed</td>
		 * 			<td>AIR_INSTALLED</td><td>AIR environment is installed</td>
		 * 			<td>APP_INSTALLED</td><td>Application is installed</td>
		 * 		</tr>
		 * </table>
		 *  
		 * @return uint
		 * 
		 */
		public function get status():uint
		{
			return _status;
		}

		public function get initialized():Boolean
		{
			return _initialized;
		}
		
		
		
		
	}
}