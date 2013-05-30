package  ru.teachbase.net
{
	/**
	 * @author Teachbase (created: Feb 21, 2012)
	 */
	public interface IService
	{
		//------------ initialize ------------//
		
		//--------------- ctrl ---------------//
		
		function connect():void;
		
		//------------ get / set -------------//
		
		function get state():String;
		
		//------- handlers / callbacks -------//
		
		function incomingCall(name:*, ...rest):*;
	}
}