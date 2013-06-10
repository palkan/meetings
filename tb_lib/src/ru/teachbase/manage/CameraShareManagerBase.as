package ru.teachbase.manage
{
import flash.events.ActivityEvent;
import flash.events.AsyncErrorEvent;
import flash.events.ErrorEvent;
import flash.events.IOErrorEvent;
import flash.events.NetStatusEvent;
import flash.media.Camera;
import flash.media.Microphone;
import flash.media.MicrophoneEnhancedMode;
import flash.media.MicrophoneEnhancedOptions;
import flash.media.SoundCodec;
import flash.net.NetConnection;
import flash.net.NetStream;

import ru.teachbase.core.App;
import ru.teachbase.events.ChangeEvent;
import ru.teachbase.events.PermissionEvent;
import ru.teachbase.events.SettingsEvent;
import ru.teachbase.events.ShareEvent;
import ru.teachbase.events.TraitEvent;
import ru.teachbase.model.CameraSettings;
import ru.teachbase.model.Packet;
import ru.teachbase.model.constants.PacketType;
import ru.teachbase.traits.PermissionTrait;
import ru.teachbase.traits.SettingsTrait;
import ru.teachbase.traits.ShareTrait;
import ru.teachbase.traits.StreamStateTrait;
import ru.teachbase.utils.Logger;
import ru.teachbase.utils.Permissions;
import ru.teachbase.utils.helpers.config;
import ru.teachbase.utils.system.requestUserMediaAccess;

/**
	 * Base manager for camera and mic sharing
	 * 
	 * @author Teachbase (created: Jun 11, 2012)
	 */
	public class CameraShareManagerBase extends Manager
	{
		
CONFIG::LIVE{
		protected var stream:NetStream;
		
		protected var camera:Camera;
		protected var microphone:Microphone;
		
		private var _s_enabled:Boolean = true;
		
		private var connection:NetConnection;
		
		
		private var trait:ShareTrait = TraitManager.instance.createTrait(ShareTrait) as ShareTrait;
		private var _p_trait:PermissionTrait;
		private var _s_trait:SettingsTrait;
		private var _st_trait:StreamStateTrait = TraitManager.instance.createTrait(StreamStateTrait) as StreamStateTrait;
		private var _streamDisposed:Boolean = true;
}
		
		/** 
		 *  Create new CameraShareManager. 
		 * 
		 * @param usePermissions	defines whether to handle permissions events
		 * @param useSettings		defines whether to handle settings events
		 * @param deps				dependencies
		 * 
		 */
		public function CameraShareManagerBase(usePermissions:Boolean = false, useSettings:Boolean = false,...deps:Array)
		{
			super(deps);
			
CONFIG::LIVE{	
			trait.initialize();
			
			trait.addEventListener(ShareEvent.STOP_SHARING,onStopSharing);
			
			if(usePermissions){
				_p_trait = TraitManager.instance.createTrait(PermissionTrait) as PermissionTrait;
				_p_trait.addEventListener(PermissionEvent.PERMISSIONS_CHANGED, permissionChanged);
			}
			
			if(useSettings){
				_s_trait = TraitManager.instance.createTrait(SettingsTrait) as SettingsTrait;
				_s_trait.addEventListener(SettingsEvent.CAMERA_ID, onCameraIdChanged);
                _s_trait.addEventListener(SettingsEvent.MICROPHONE_ID, onMicIdChanged);
				_s_trait.addEventListener(SettingsEvent.CAMERA_QUALITY, onQualityChanged);
			}
			
			_st_trait.addEventListener(ChangeEvent.CHANGED, onStreamStatusChanged);
			
}
		}
		
		
		
		override protected function initialize():void{

CONFIG::LIVE{
			connection = App.service.media_connection;
}
			_initialized = true;

		}	
		
		

CONFIG::LIVE{
		
		public function toggleStartAll():void{
			(videoSharing && closeCameraSharing()) || start();
		}
		
		public function toggleStartAudio():void{
			(audioSharing && ((videoSharing && muteAudio()) || closeAudioSharing())) || start(true,false);
		}
		
		
		protected function onStopSharing(event:ShareEvent):void
		{
			if(!(event.value is int))
				return;
			
			if((event.value & 2) && (event.value & 1)){
				closeAll();
				return;
			}
			
			(event.value & 2) && closeCameraSharing();
			
			(event.value & 1) && ((videoSharing && muteAudio()) || closeAudioSharing());
				
		}
		
		//------------ initialize ------------//
		
		
		public function enable():void
		{
			App.room.sharing.enabled = true;
		}
		
		public function disable():void
		{
			App.room.sharing.enabled = false;
		}
		
		//--------------- ctrl ---------------//
		
			
		public function closeCameraSharing(commit:Boolean = true):Boolean
		{
			if(!videoSharing)
				return false;
			
			if(stream)
			{
				stream.attachCamera(null);
			}
			
			videoSharing = false;
			TraitManager.instance.dispatchEvent(new TraitEvent(PacketType.I_CAMERA, new Packet(PacketType.I_CAMERA,null)));
		
			commit && statusUpdate();
			
			return true;
		}
		
		public function closeAudioSharing(commit:Boolean = true):Boolean{
			if(!audioSharing)
				return false;
			
			if(stream)
			{
				stream.attachAudio(null);
			}
			
			audioSharing = false;
			
			commit && statusUpdate();
			
			return true;
		}


        public function muteAudio(commit:Boolean = true):Boolean{

            if(!microphone) return false;

            microphone.gain = 0;

            audioSharing = false;

            commit && statusUpdate();

            return true;

        }

        public function unmuteAudio(commit:Boolean = true):Boolean{

            if(!microphone) return false;

            microphone.gain = config(SettingsEvent.MICROPHONE_VOLUME,80);

            audioSharing = true;

            commit && statusUpdate();

            return true;
        }
		
				
		public function start(audio:Boolean = true,video:Boolean = true):void
		{
			if(!_s_enabled || (!audio && !video))
				return;
			
			//!audioSharing && (audioSharing = audio);
			//!videoSharing && (videoSharing = video);
			
			!_streamDisposed && success(false);
			_streamDisposed && requestUserMediaAccess(-1,-1,success,failure,App.stage);
			
			function success(status:Boolean):void{
				initStream();
                audio && ((videoSharing && unmuteAudio(false)) || startAudioSharing(false));
				video && startVideoSharing(false);
				status && (videoSharing || audioSharing) && stream.publish('stream',App.room.user.sid.toString());
				statusUpdate();
			}	
			
			function failure(error:String):void{
				Logger.log(error,"share_access");
				audioSharing = videoSharing = false;
			}
			
			
		}
		
		public function closeAll():void
		{
			closeCameraSharing(false);
			closeAudioSharing(false);
			statusUpdate();
		}
		
		public function startAudioSharing(commit:Boolean = true):void{
			
				
			if(setMicrophone()){
                stream.attachAudio(null);
				stream.attachAudio(microphone);
				audioSharing = true;
			
				commit && statusUpdate();
			}else
				audioSharing = false;
			
		}
		
		
		public function startVideoSharing(commit:Boolean = true):void{
			
			if(setCamera()){

				//if(camera.activityLevel<0)
					//camera.addEventListener(ActivityEvent.ACTIVITY,camActiveHandler);
				//else
					stream.attachCamera(camera);

					TraitManager.instance.dispatchEvent(new TraitEvent(PacketType.I_CAMERA, new Packet(PacketType.I_CAMERA,camera)));
			
			        videoSharing = true;

					commit && statusUpdate();
			}else
 				videoSharing = false;
			
		}
		
		
		private function camActiveHandler(e:ActivityEvent):void{
            Logger.log('Activating: '+ e.activating,'cam');
			if(e.activating){

				camera.removeEventListener(ActivityEvent.ACTIVITY,camActiveHandler);
                stream.attachCamera(null);
				stream.attachCamera(camera);
			}
		}
		
		protected function initStream():void{
			if (stream == null) {
				stream = new NetStream(App.service.media_connection);
				var ns_client:Object = new Object();
				ns_client.onMetaData = function(metadata:Object):void {
					//nothing to do
				};
				stream.client = ns_client;
				stream.addEventListener(NetStatusEvent.NET_STATUS, nsPublishOnStatus);
				stream.addEventListener(AsyncErrorEvent.ASYNC_ERROR,onError);
				stream.addEventListener(IOErrorEvent.IO_ERROR,onError);
				stream.bufferTime = 0;
			}
			_streamDisposed = false;
		}
		
		public function pauseCameraSharing():void{
			stream.attachCamera(null);
		}
		
		public function playCameraSharing():void{
			if (camera != null)
				stream.attachCamera(camera);
		}
		
		protected function statusUpdate():void{
			
			var status:uint = (uint(videoSharing) << 2) | (uint(audioSharing) << 1);
			
			if(status === 0 && stream){
				stream.dispose();
				//stream = null;
				_streamDisposed = true;
			}
			
			
			trait.status = status;

			
		}
		
		
		//------------ get / set -------------//
		
		
		private function setCamera(force:Boolean = false):Camera{
			
			if(!videoSharing || force){
				camera = Camera.getCamera(config(SettingsEvent.CAMERA_ID,null));
				if (!camera) {
					camera = Camera.getCamera();
				}
				
				if(!camera) return null;							
				
				CameraSettings.setPreset(camera, stream, config(SettingsEvent.CAMERA_QUALITY,CameraSettings.PRESET2));
				//camera.setKeyFrameInterval(4); 
				camera.setLoopback(true);
			}
			
			return camera;
			
		}
		
		
		protected function setMicrophone(force:Boolean = false):Microphone {
			if(!audioSharing || force){
				var options:MicrophoneEnhancedOptions = new MicrophoneEnhancedOptions();
				options.mode = MicrophoneEnhancedMode.FULL_DUPLEX;
				options.echoPath = 128;
				options.nonLinearProcessing = true;
				microphone = Microphone.getEnhancedMicrophone(int(config(SettingsEvent.MICROPHONE_ID,-1)));
				if (!microphone) {microphone = Microphone.getEnhancedMicrophone()}
				
				if(!microphone) return null;
				
				microphone.enhancedOptions = options;
				microphone.gain = config(SettingsEvent.MICROPHONE_VOLUME,80);
				microphone.codec = SoundCodec.SPEEX;
				microphone.framesPerPacket = 2;
				microphone.rate = 11;
				microphone.setSilenceLevel(0);
				microphone.encodeQuality = 5;
				microphone.setLoopBack(false);
				microphone.setUseEchoSuppression(true);
			}
			
			
			return microphone;
		}
		
		
		//------- handlers / callbacks -------//
		
		protected function onStreamStatusChanged(e:ChangeEvent):void{
			
			switch(e.value){
				
				case "disconnect":
					closeAll();
					stream = null;
					_s_enabled = false;
					break;
				case "connect":
					_s_enabled = true;
					break;
			}
			
		}
		
		
		protected function onMicIdChanged(event:SettingsEvent):void
		{
            /*microphone = setMicrophone(true);
            if(stream)
                stream.attachAudio(microphone);
                */
		}


        protected function onCameraIdChanged(event:SettingsEvent):void
        {
            /*camera = setCamera(true);

            if(stream)
                stream.attachCamera(camera);
            TraitManager.instance.dispatchEvent(new TraitEvent(PacketType.I_CAMERA, new Packet(PacketType.I_CAMERA,camera)));    */
        }

		protected function onQualityChanged(event:SettingsEvent):void
		{
			CameraSettings.setPreset(camera, stream, int(event.setting.value));
		}
		
		protected function permissionChanged(event:PermissionEvent):void{
			if (!Permissions.camAvailable(event.value)) {
				closeCameraSharing();
			}
			
			if (!Permissions.micAvailable(event.value)) {
				closeAudioSharing();
			}
			
		}
		
		
		protected function onError(event:ErrorEvent):void{
			
			Logger.log("io error","camerashare");
			
		}
		
		protected function nsPublishOnStatus(infoObject:NetStatusEvent) : void
		{
			Logger.log(infoObject.info.code,"NetStatusShare")
		}
		
		private function changeHandler(e:TraitEvent):void
		{
			if (e.packet.type == PacketType.CAMERA_QUALITY) {
				CameraSettings.setPreset(camera, stream, int(e.packet.data));
			}
			
			if (e.packet.type == PacketType.STOP_STREAMING) {
				closeCameraSharing();
			}
		}

		public function get audioSharing():Boolean
		{
			return App.room.sharing.audioSharing;
		}

		public function set audioSharing(value:Boolean):void
		{
			App.room.sharing.audioSharing = value;
		}

		public function get videoSharing():Boolean
		{
			return App.room.sharing.videoSharing;
		}

		public function set videoSharing(value:Boolean):void
		{
			App.room.sharing.videoSharing = value;
		}

}
	}
}
