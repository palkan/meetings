package ru.teachbase.net.factory
{
import flash.events.EventDispatcher;

public class ConnectionFactory extends EventDispatcher
	{
		
		private const DEFAULT_PROTOCOL_PORT_SEQUENCE:String = "rtmp:1935,rtmp:443,rtmpt:80";
		
		
		private var _connections:Object = {};
		
		
		public function ConnectionFactory()
		{
			super();
			
		}
		
		
		private function onEvent(e:ConnectionFactoryEvent):void{
			dispatchEvent(new ConnectionFactoryEvent(e.type,e.connection));
		}
		
		public function createConnection(url:String):void{
			
			var pattern:RegExp = /^([a-z+\w\+\.\-]+:\/\/)?([^\/?#]*)?(\/[^?#]*)?(\?[^#]*)?(\#.*)?/i;		
			var result:Array = url.match(pattern);
			var hostName:String;
			var path:String;
			
			if (result != null)
			{
				hostName = result[2];
				path = result[3];
				
				var _ng:NetConnectionNegotiator = new NetConnectionNegotiator();
				_ng.addEventListener(ConnectionFactoryEvent.CREATED,onEvent);	
				_ng.addEventListener(ConnectionFactoryEvent.CONNECT_ERROR,onEvent);
				_ng.addEventListener(ConnectionFactoryEvent.CONNECT_TIMEOUT,onEvent);
				_ng.createNetConnection(hostName,path,DEFAULT_PROTOCOL_PORT_SEQUENCE);
				
			}
				
			
		}
		
	}
}