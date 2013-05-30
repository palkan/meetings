package ru.teachbase.model
{
	
	/**
	 * @author Teachbase (created: Oct 30, 2012)
	 */
	[Bindable]
	
	public class SharingModel
	{

        public static const MIC_SHARED:uint = 1;
        public static const CAM_SHARED:uint = 1 << 1;

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

        public function get status():uint{
            return (uint(videoSharing) << CAM_SHARED) | (uint(audioSharing) << MIC_SHARED);
        }
		
		//------- handlers / callbacks -------//
		
	}
}
