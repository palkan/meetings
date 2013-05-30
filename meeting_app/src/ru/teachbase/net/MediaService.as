package ru.teachbase.net
{
import flash.events.ErrorEvent;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.NetStatusEvent;
import flash.net.NetConnection;
import flash.utils.setTimeout;

import ru.teachbase.events.TraitEvent;
import ru.teachbase.manage.TraitManager;
import ru.teachbase.model.NetModel;
import ru.teachbase.model.Packet;
import ru.teachbase.model.constants.PacketType;
import ru.teachbase.net.factory.ConnectionFactoryEvent;
import ru.teachbase.utils.Logger;

[Event(name="complete", type="flash.events.Event")]
	[Event(name="error", type="flash.events.ErrorEvent")]
	
	public class MediaService extends EventDispatcher
	{
		private const RECONNECT_INTERVAL:uint = 1000;
		private const RECONNECT_TRIES:uint = 5;
		
		private var recon_count:int = 0;
		
		private var _url:String;		
		private var _connection:NetConnection;
		/**
		 *  
		 * @param url URL of RTMP server
		 * 
		 */		
		
		public function MediaService(url:String)
		{
			_url = url;			
			
		}
		
		
		public function dispose():void{
			
			if(!_connection)
				return;
			
			_connection.removeEventListener(NetStatusEvent.NET_STATUS, onNetStatus);
			_connection.connected && _connection.close();
			
			
		}
		
		
		public function connect():void{
			
			NetModel.factory.addEventListener(ConnectionFactoryEvent.CREATED,onConnectionComplete);	
			NetModel.factory.addEventListener(ConnectionFactoryEvent.CONNECT_ERROR,onConnectionError);
			
			NetModel.factory.createConnection(_url);
			
		}
		
		protected function onConnectionError(event:ConnectionFactoryEvent):void
		{
			NetModel.factory.removeEventListener(ConnectionFactoryEvent.CREATED,onConnectionComplete);	
			NetModel.factory.removeEventListener(ConnectionFactoryEvent.CONNECT_ERROR,onConnectionError);
			
			
			tryToReconnect();
		}
		
		
		private function tryToReconnect():void{
			
			
			if(recon_count > RECONNECT_TRIES)
				dispatchEvent(new ErrorEvent(ErrorEvent.ERROR));
			else{
				Logger.log('try #'+(recon_count+1).toString(), "MEDIA");
					
				TraitManager.instance.dispatchEvent(new TraitEvent(PacketType.STREAM_STATUS,new Packet(PacketType.STREAM_STATUS,"disconnect")));
				recon_count++;
				setTimeout(connect,RECONNECT_INTERVAL);
			}
		}
		
		protected function onConnectionComplete(event:ConnectionFactoryEvent):void
		{
			recon_count = 0;
			
			Logger.log('connected', "MEDIA");
			
			
			_connection = event.connection;
			
			NetModel.factory.removeEventListener(ConnectionFactoryEvent.CREATED,onConnectionComplete);	
			NetModel.factory.removeEventListener(ConnectionFactoryEvent.CONNECT_ERROR,onConnectionError);
			
			_connection.addEventListener(NetStatusEvent.NET_STATUS,onNetStatus);
			
			TraitManager.instance.dispatchEvent(new TraitEvent(PacketType.STREAM_STATUS,new Packet(PacketType.STREAM_STATUS,"connect")));
			
			dispatchEvent(new Event(Event.COMPLETE));
			
		}		
		
		protected function onNetStatus(e:NetStatusEvent):void
		{
			
			Logger.log('Status: '+e.info.code, "MEDIA");
			
			
			if(e.info.level === 'error')
			{
				tryToReconnect();
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
					tryToReconnect();			
					break;
				}
			}
		}
		
		public function get connection():NetConnection
		{
			return _connection;
		}

		
	}
}