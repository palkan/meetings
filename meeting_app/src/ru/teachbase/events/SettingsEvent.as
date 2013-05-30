package ru.teachbase.events
{

import flash.events.Event;

import ru.teachbase.model.Setting;

public class SettingsEvent extends Event
	{
		
		public static const MICROPHONE_ID:String = 'microphoneid';
		public static const MICROPHONE_VOLUME:String = 'microphonevolume';
		public static const MICROPHONE_SILENCE:String = 'microphonesilence';
		public static const RECCORD_ON:String =  'reccordon';
		public static const VOLUME:String = 'volume';
		public static const VOLUME_MUTE:String = 'volumemute';
		public static const LANGUAGE:String = 'language';
		public static const ORGANIZATOR_CURSOR:String = 'organizatorcursor';
		public static const CAMERA_QUALITY:String = 'cameraquality';
		public static const CAMERA_ID:String = 'cameraid';
		public static const VOLUME_LIMIT:String = 'volumelimit';
		public static const NOTIFICATION_ENABLED:String = 'notification_enabled';
		public static const CAMERA_REQUEST_ENABLED:String = 'camera_request_enabled'; 
		
		private var _setting:Setting;
		public function SettingsEvent(type:String, value:Setting)
		{
			super(type);
			_setting = value;
		}

		public function get setting():Setting
		{
			return _setting;
		}

	}
}