package ru.teachbase.model
{
import flash.media.Camera;
import flash.media.H264Level;
import flash.media.H264Profile;
import flash.media.H264VideoStreamSettings;
import flash.net.NetStream;

public class CameraSettings
	{
		private static var PRESET1_QUALITY:int = 60;
		private static var PRESET1_KEYFRAMEINTERVAL:int = 10;
		private static var PRESET1_FPS:int = 15;
		private static var PRESET1_WIDTH:Number = 160;
		private static var PRESET1_HEIGHT:Number = 120;
		private static var PRESET1_BANDWIDTH:int = 0;
		
		private static var PRESET2_QUALITY:int = 75;
		private static var PRESET2_KEYFRAMEINTERVAL:int = 10;
		private static var PRESET2_FPS:int = 15;
		private static var PRESET2_WIDTH:Number = 320;
		private static var PRESET2_HEIGHT:Number = 240;
		private static var PRESET2_BANDWIDTH:int = 0;
		
		private static var PRESET3_QUALITY:int = 90;
		private static var PRESET3_KEYFRAMEINTERVAL:int = 10;
		private static var PRESET3_FPS:int = 15;
		private static var PRESET3_WIDTH:Number = 480;
		private static var PRESET3_HEIGHT:Number = 360;
		private static var PRESET3_BANDWIDTH:int = 0;
		
		public static const PRESET1:int = 1;
		public static const PRESET2:int = 2;
		public static const PRESET3:int = 3;
		
		public function CameraSettings()
		{
		}
		
		public static function setPreset(cam:Camera = null, stream:NetStream = null, preset:int = 1):void{
			switch (preset) {
				case 1:
					setPreset1(cam, stream);
					break;
				case 2:
					setPreset2(cam, stream);
					break;
				case 3:
					setPreset3(cam, stream);
					break;
			}
		}
		
		private static function setPreset1(cam:Camera, stream:NetStream):void{	
			if (cam == null) {return};
			cam.setMode(PRESET1_WIDTH, PRESET1_HEIGHT,PRESET1_FPS)
			cam.setKeyFrameInterval(PRESET1_KEYFRAMEINTERVAL);
			cam.setQuality(PRESET1_BANDWIDTH, PRESET1_QUALITY);
			if (stream == null) {return};
			var h264Settings:H264VideoStreamSettings = new H264VideoStreamSettings();
			h264Settings.setProfileLevel(H264Profile.BASELINE, H264Level.LEVEL_1);
			stream.videoStreamSettings = h264Settings;
		}
		
		private static function setPreset2(cam:Camera, stream:NetStream):void{	
			if (cam == null) {return};
			cam.setMode(PRESET2_WIDTH, PRESET2_HEIGHT,PRESET2_FPS)
			cam.setKeyFrameInterval(PRESET2_KEYFRAMEINTERVAL);
			cam.setQuality(PRESET2_BANDWIDTH, PRESET2_QUALITY)		
			if (stream == null) {return};
			var h264Settings:H264VideoStreamSettings = new H264VideoStreamSettings();
			h264Settings.setProfileLevel(H264Profile.MAIN, H264Level.LEVEL_3_1);
			stream.videoStreamSettings = h264Settings;
		}
		
		private static function setPreset3(cam:Camera, stream:NetStream):void{	
			if (cam == null) {return};
			cam.setMode(PRESET3_WIDTH, PRESET3_HEIGHT,PRESET3_FPS)
			cam.setKeyFrameInterval(PRESET3_KEYFRAMEINTERVAL);
			cam.setQuality(PRESET3_BANDWIDTH, PRESET3_QUALITY);
			if (stream == null) {return};
			var h264Settings:H264VideoStreamSettings = new H264VideoStreamSettings();
			h264Settings.setProfileLevel(H264Profile.MAIN, H264Level.LEVEL_3_2);
			stream.videoStreamSettings = h264Settings;
		}

	}
	
}