package ru.teachbase.net.factory
{
import flash.events.Event;
import flash.net.NetConnection;

public class ConnectionFactoryEvent extends Event
	{
		
		public static const CREATED:String = "connectionCreated";
		public static const CONNECT_ERROR:String = "connectionError";
		public static const CONNECT_TIMEOUT:String = "connectionTimeout";
		
		private var _connection:NetConnection;
		
		public function ConnectionFactoryEvent(type:String, connection:NetConnection = null, bubbles:Boolean = true)
		{
			super(type, bubbles, cancelable);
			_connection = connection;
		}

		public function get connection():NetConnection
		{
			return _connection;
		}

	}
}