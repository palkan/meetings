package ru.teachbase.net
{
import flash.events.ErrorEvent;
import flash.events.Event;
import flash.events.NetStatusEvent;
import flash.net.NetConnection;
import flash.net.Responder;
import flash.utils.Timer;
import flash.utils.setTimeout;

import mx.rpc.IResponder;

import ru.teachbase.core.App;
import ru.teachbase.events.TraitEvent;
import ru.teachbase.manage.__manage;
import ru.teachbase.manage.rtmp.RTMPClient;
import ru.teachbase.model.NetModel;
import ru.teachbase.model.Packet;
import ru.teachbase.model.User;
import ru.teachbase.model.constants.PacketType;
import ru.teachbase.model.constants.ServiceState;
import ru.teachbase.net.factory.ConnectionFactoryEvent;
import ru.teachbase.utils.BrowserUtils;
import ru.teachbase.utils.GlobalError;
import ru.teachbase.utils.Logger;
import ru.teachbase.utils.helpers.config;

/**
	 * @author Webils (created: Feb 27, 2012)
	 */
	public class Service implements IService
	{
		public static const PROP_STATE:String = 'state';
		
		//private const RECONNECT_INTERVAL:uint = 100;
		private const RECONNECT_TRIES:uint = 10;

		protected const dataConverter:Object = new Object();
		
		protected var _client:RTMPClient;
		protected var _state:String = ServiceState.UNKNOWN;
		
		private var _token:String;
		
		private var recon_counter:uint = RECONNECT_TRIES+1;
		
		private var recon_timer:Timer;
		
		public  var connection:NetConnection;
		
		//------------ dependent services ------//
		
		public  var http:HTTPService;
		
		private  var media:MediaService;
		
		//------------ constructor ------------//
		
		public function Service()
		{
		}
		
		protected function onConnectionError(event:ConnectionFactoryEvent):void
		{
			
			NetModel.factory.removeEventListener(ConnectionFactoryEvent.CREATED,onConnectionComplete);	
			NetModel.factory.removeEventListener(ConnectionFactoryEvent.CONNECT_ERROR,onConnectionError);
			NetModel.factory.removeEventListener(ConnectionFactoryEvent.CONNECT_TIMEOUT,onConnectionTimeout);
			
			if(recon_counter > RECONNECT_TRIES)
				GlobalError.raise(ServiceState.CLOSED);
			else
				tryToReconnect();
		}
		
		
		protected function onConnectionTimeout(event:ConnectionFactoryEvent):void
		{
			NetModel.factory.removeEventListener(ConnectionFactoryEvent.CREATED,onConnectionComplete);	
			NetModel.factory.removeEventListener(ConnectionFactoryEvent.CONNECT_ERROR,onConnectionError);
			NetModel.factory.removeEventListener(ConnectionFactoryEvent.CONNECT_TIMEOUT,onConnectionTimeout);
			
			GlobalError.raise(ServiceState.TIMEOUT);
			
		}
		
		protected function onConnectionComplete(event:ConnectionFactoryEvent):void
		{
			recon_counter = 0;
			NetModel.factory.removeEventListener(ConnectionFactoryEvent.CREATED,onConnectionComplete);	
			NetModel.factory.removeEventListener(ConnectionFactoryEvent.CONNECT_ERROR,onConnectionError);
			NetModel.factory.removeEventListener(ConnectionFactoryEvent.CONNECT_TIMEOUT,onConnectionTimeout);
			
			connection = event.connection;
			connection.client = _client = new RTMPClient(this);
			
			connection.addEventListener(NetStatusEvent.NET_STATUS, statusHandler);
		
			if(config("service::rtmp_media",false)){
				
				Logger.log("media: "+config("service::rtmp_media")+NetModel.NAMESPACE,"service");
				
				media = new MediaService(config("service::rtmp_media")+NetModel.NAMESPACE);
				media.addEventListener(Event.COMPLETE,onMediaComplete);
				media.addEventListener(ErrorEvent.ERROR,onMediaError);
			
				media.connect();
				
			}else{
				if(App.room.user)
					newState = ServiceState.READY;
				else
					newState = ServiceState.CONNECTED;
			}

		}
		
		protected function onMediaError(event:ErrorEvent):void
		{
			GlobalError.raise(ServiceState.STREAM_ERROR);
		}
		
		private function onMediaComplete(e:Event):void{
		
			media.removeEventListener(Event.COMPLETE,onMediaComplete);
			
			if(App.room.user)
				newState = ServiceState.READY;
			else
				newState = ServiceState.CONNECTED;
			
			
		}		
		
		
		
		//------------ initialize ------------//
		
		public function initialize():void
		{
            if(_state != ServiceState.UNKNOWN)
                return;

			App.traitManager.__manage::registerService(this);
			newState = ServiceState.INITIALIZED;
		}
		
		/**
		 *  @private
		 *  Shuts down the underlying NetConnection for the channel.
		 */
		public function dispose():void
		{
			
			media && media.dispose();
			
			if(!connection)
				return;
			
			connection.removeEventListener(NetStatusEvent.NET_STATUS, statusHandler);
			connection.connected && connection.close();
            _state = ServiceState.UNKNOWN;
		}
		
		//-------- data conversations --------//
		// none //
		
		//--------------- ctrl ---------------//
		
		public function connect():void
		{
			newState = ServiceState.CONNECTING;
			
			NetModel.factory.addEventListener(ConnectionFactoryEvent.CREATED,onConnectionComplete);	
			NetModel.factory.addEventListener(ConnectionFactoryEvent.CONNECT_ERROR,onConnectionError);
			NetModel.factory.addEventListener(ConnectionFactoryEvent.CONNECT_TIMEOUT,onConnectionTimeout);
			
			NetModel.factory.createConnection(config("service::rtmp_main","")+NetModel.NAMESPACE);
			
		}
		
		public function login(userID:uint, roomID:uint):void
		{
			new User();
			
			App.room.id = roomID;
			
			newState = ServiceState.AUTHORIZATION;
			
			Logger.log('logging in: '+ userID.toString()+" "+ roomID.toString(),"service");
			
			//format: {user_id:int, meeting_id:int, options:*}
			
			if(config("guest",false))
				connection.call('login', new Responder(loginSuccess, loginError), userID, roomID, 'guest', config("name","user_name"), config("role","user"));
			else
				connection.call('login', new Responder(loginSuccess, loginError), userID, roomID);
			
			function loginSuccess(args:Array):void
			{
				_token = args[0];
				App.room.user = args[1];
				
				if(config("service::http",false))
					http = new HTTPService(args[2]);
				
				newState = ServiceState.AUTHORIZED;
			}
			
			function loginError(error:*):void
			{
				Logger.log("login error","error");
				GlobalError.raise(ServiceState.AUTHORIZATION_FAILED);
				Logger.log('LOGIN ERROR: '+ error.toString(),"service");
			}
			
			
		}
		
		/**
		 * 
		 * @param kind see <code>ClientOperationKind</code>
		 * @param name method's name
		 * @param rest arguments
		 * @return result
		 * 
		 */		

		
		
		
		
		private function tryToReconnect():void{
			
			Logger.log("try to reconnect","error");
			GlobalError.raise(ServiceState.CLOSED);
					
			setTimeout(BrowserUtils.reloadWindow,5000);
			
			
		}
		
		/*protected function onReconTimer(event:TimerEvent):void
		{
				connect();
		}		*/
		
		//------------ get / set -------------//
		
		public function get state():String
		{
			return _state;
		}
		
		private function set newState(value:String):void
		{
			if(_state === value)
				return;
			
			const old:String = _state;
			_state = value;
			
			App.traitManager.dispatchEvent(new TraitEvent(PacketType.STATE, new Packet(PacketType.STATE,{level:'state',code:_state})));
		}
		
		
		
		/**
		 * 
		 * @return NetConnection for streams 
		 * 
		 */
		public function get media_connection():NetConnection{
			if(media && media.connection)
				return media.connection;
			else
				return connection;
		}
		
		
		//------- handlers / callbacks -------//
		
		protected function statusHandler(e:NetStatusEvent):void
		{
			
			
			if(e.info.level === 'error')
			{
				Logger.log("Connection error","error");
				GlobalError.raise(ServiceState.CLOSED);
				return;
			}
			
				
			switch(e.info.code)
			{
				case "NetConnection.Connect.Failed":
				{
					tryToReconnect();
					break;
				}
					
				case "NetConnection.Connect.Success":
				{
					break;
				}
					
				case "NetConnection.Connect.Closed":
				{
					Logger.log("Connection closed","error");
					tryToReconnect();			
					break;
				}
			}
		}
		
		
	}
}
