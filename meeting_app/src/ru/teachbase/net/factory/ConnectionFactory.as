package ru.teachbase.net.factory
{
import flash.events.EventDispatcher;
import flash.net.NetConnection;

public class ConnectionFactory extends EventDispatcher
	{
		
		private const DEFAULT_PROTOCOL_PORT_SEQUENCE:String = "rtmp:1935,rtmp:443,rtmpt:80";
		private var _ng:NetConnectionNegotiator = new NetConnectionNegotiator();

		private var _connections:Object = {};
		
		
		public function ConnectionFactory()
		{
			super();
			
		}

		public function createConnection(url:String):void{
			
			var pattern:RegExp = /^([a-z+\w\+\.\-]+:\/\/)?([^\/:?#]*)?(:\d+)?(\/[^?#]*)?(\?[^#]*)?(\#.*)?/i;
			var result:Array = url.match(pattern);
			var hostName:String;
			var path:String;
            var protocol:String;
            var port:String;
			
			if (result != null)
			{
                protocol = result[1] ? result[1] : '';
				hostName = result[2];
                port = result[3] ? ':'+result[3]+',' : '';
				path = result[4];
				
				_ng.createNetConnection(hostName,path,protocol+port+DEFAULT_PROTOCOL_PORT_SEQUENCE);
			}
				
			
		}

        public function get ng():NetConnectionNegotiator{
            return _ng;
        }

        public function get connection():NetConnection{
            return _ng.nc;
        }
		
	}
}