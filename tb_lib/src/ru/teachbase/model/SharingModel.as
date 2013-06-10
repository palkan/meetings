package ru.teachbase.model
{
	
	/**
	 * @author Teachbase (created: Oct 30, 2012)
	 */
	[Bindable]
	
	public class SharingModel
	{
		
		private var _enabled:Boolean = false;
		
		public var audioSharing:Boolean = false;
		
		public var videoSharing:Boolean = false;
		
		
		public function SharingModel()
		{
			
		}
		
		//------------ initialize ------------//
		
		//--------------- ctrl ---------------//
		
		//------------ get / set -------------//
		
		public function get enabled():Boolean
		{
			return _enabled;
		}
		
		public function set enabled(value:Boolean):void
		{
			_enabled = value;
			
			if(!_enabled)
				audioSharing = videoSharing = false;
		}
		
		//------- handlers / callbacks -------//
		
	}
}
