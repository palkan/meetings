package ru.teachbase.constants
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
		public static const DOCUMENT:String = "document";
		public static const CHAT:String = 'chat';
		public static const WHITEBOARD:String = 'whiteboard';
		public static const USERS:String = "users";
        public static const MEETING:String = "meeting";
		public static const SETTINGS_CHANGED:String = 'settingsChanged';
		public static const SCREEN_SHARING:String = 'screen_sharing';
        public static const MODULE:String = "modules";
        public static const STREAM:String = "stream";
        public static const PUBLISH:String = "publish";

	}
}