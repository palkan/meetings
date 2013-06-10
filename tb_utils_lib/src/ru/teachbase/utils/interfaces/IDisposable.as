package ru.teachbase.utils.interfaces
{
	
	/**
	 * @author Teachbase (created: Jan 25, 2012)
	 */
	public interface IDisposable
	{
		//------------ initialize ------------//
		
		//--------------- ctrl ---------------//
		
		/**
		 * Prepare for clean memory: break all links.
		 */		
		function dispose():void;
		
		//------------ get / set -------------//
		
		function get disposed():Boolean;
		
		//------- handlers / callbacks -------//
	}
}