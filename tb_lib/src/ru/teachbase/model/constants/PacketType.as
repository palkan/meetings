package ru.teachbase.model.constants
{
	/**
	 * Class contains static constants: <b>types of Packet</b> strings
	 * @author Teachbase (created: May 2, 2012)
	 */
	public final class PacketType
	{
		//-------- External types ------------//
		
		public static const CURSOR:String = "live_cursor";
		public static const LAYOUT:String = "layout";
		public static const SHARING:String = "sharing";
		public static const DOCUMENT:String = "document";
		public static const CHAT:String = 'text';
		public static const PRIVATE_CHAT:String = 'privateChat';
		public static const WHITEBOARD:String = 'whiteboard';
		public static const ROOM_CHANGES:String = "room_changes";
		public static const SETTINGS_CHANGED:String = 'settingsChanged';
		public static const SCREEN_SHARING:String = 'screen_sharing';
		
		public static const CALL_ONLY:String = 'call_only';
		
		// deprecated
		public static const FILE:String = "file";
				
		
		//---------- State types -----------------//
		
		public static const STREAM_STATUS:String = "stream_status";
		public static const STATE:String = "state";
		
		
		//---------- Local types ---------------//
		
		public static const PERMISSSON:String = "permission";
		public static const STREAM:String = 'stream'; 
		public static const I_VIDEO:String = "i_video"; 
		public static const I_CAMERA:String = "i_camera"; 
		public static const NOTIFICATION:String = 'notification';
			
		
		public static const CAMERA_QUALITY:String = "cameraQuality";
		public static const STOP_STREAMING:String ="stop_streaming";
		public static const LANGUAGE:String = "language";
		
		
		//public static const MICROPHONE_ID:String = "microphoneId";
		//public static const MICROPHONE_VOLUME:String = "microphoneVolume";
		//public static const MICROPHONE_SILENCE:String = "microphoneSilence";
		
		//public static const RECCORD_ON:String = "reccord_on";
		
	//	public static const VOLUME:String = "volume";
		//public static const VOLUME_MUTE:String = "volumeMute";
	//	
		//public static const ORGANIZATOR_CURSOR:String = "organizatorCursor";
		
		
				
		
		
	}
}