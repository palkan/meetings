package ru.teachbase.model.constants
{
	
	/**
	 * @author  (created: May 4, 2012)
	 */
	public final class ServiceState
	{
		public static const UNKNOWN:String = 'unknown';
		public static const TIMEOUT:String = 'timeout';
		public static const LIMIT:String = 'limit';
		public static const NOT_FOUND:String = 'not_found';
		public static const INITIALIZING:String = 'initializing';
		public static const INITIALIZED:String = 'initialized';
		
		public static const AUTHORIZATION_FAILED:String = "authorization_failed";
		
		public static const MEETING_FINISHED:String = 'meeting_finished';
		
		public static const CONNECTING:String = 'connecting';
		public static const CONNECTED:String = 'connected';
		public static const CLOSED:String = 'closed';
		
		public static const AUTHORIZATION:String = 'authorization';
		public static const AUTHORIZED:String = 'authorized';
		
		public static const READY:String = 'ready';
		
		public static const RECONNECTING:String = "reconnecting";
		
		public static const KICKEDOFF:String = "kicked";
		
		public static const STREAM_ERROR:String = "stream_error";
	}
}