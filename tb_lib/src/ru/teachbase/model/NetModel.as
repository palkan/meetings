package ru.teachbase.model
{
import ru.teachbase.net.factory.ConnectionFactory;

/**
	 * @author Teachbase (created: Apr 26, 2012)
	 */
	public class NetModel
	{
		public static const HOST:String = CONFIG::RTMP;
		public static const STREAM_HOST:String = CONFIG::RTMP;
		private static var _ns:String;
		public static const EARLY:String = HOST + NAMESPACE;
		public static const EARLY_STREAM:String = STREAM_HOST + NAMESPACE;

		public static const RECORD_APP:String = "/record";
		public static const MAIN_APP:String  = "/app";
		
		public static const factory:ConnectionFactory = new ConnectionFactory();
		
		//------------ constructor ------------//
		
		public function NetModel(namespace:String = "/app")
		{
			_ns = namespace;
		}
		
		//------------ initialize ------------//
		
		//--------------- ctrl ---------------//
		
		//------------ get / set -------------//
		
		
		public static function get NAMESPACE():String{
			
			return _ns;
			
		}
		
		//------- handlers / callbacks -------//
		
	}
}