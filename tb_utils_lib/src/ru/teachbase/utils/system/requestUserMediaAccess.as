package ru.teachbase.utils.system
{
import flash.display.Stage;
import flash.events.MouseEvent;
import flash.events.StatusEvent;
import flash.media.Camera;
import flash.media.Microphone;
import flash.media.Video;
import flash.media.scanHardware;
import flash.net.NetConnection;
import flash.net.NetStream;
import flash.utils.setTimeout;

import ru.teachbase.utils.logger.Logger;
import ru.teachbase.utils.shortcuts.debug;

/**
	 * 
	 * @param mic/cam  indexes in <code>names</code> array in <code>Camera</code> or <code>Microphone</code> classes. <br/>
	 * 	<b>- values</b>: <br/>
	 * -2 = do not try get access;
	 * <br/>
	 * -1 = request access to <b>default</b> media-device;
	 * <br/>
	 * 0+ = request access to media-device by zero-based index position within the Camera.names (or Microphone.names) array.
	 * 
	 * @param result If user allowed media access then <code>result()</code> is called; otherwise <code>fault()</code>
	 * @param fault
	 * 
	 * @param stage main stage object (we need it to detect when player closes secutiry dialog)
	 *  
	 * @author Teachbase (created: Jun 19 - Oct 29, 2012)
	 */	
	public function requestUserMediaAccess(mic:int = -2, cam:int = -2, result:Function = null, fault:Function = null, stage:Stage = null):void
	{
		scanHardware();
		
		const needMic:Boolean = mic >= -1;
		const needCam:Boolean = cam >= -1;
		
		var status:Boolean = false;
		
		const connection:NetConnection = new NetConnection();
		connection.connect(null);
		
		const stream:NetStream = new NetStream(connection);
		var target:*;
		var video:Video;
		
		// try use camera:
		if(needCam && Camera.isSupported && Camera.names.length > 0)
		{
			const camera:Camera = cam === -1 ? Camera.getCamera() : Camera.getCamera(cam.toString());
			if(camera && camera.muted)
			{
				camera.addEventListener(StatusEvent.STATUS, camStatusHandler);
				target = camera;
				video = new Video();
				video.attachCamera(camera);
				stream.attachCamera(camera);
				stream.publish('devnull');
			}
			else{
				result && result is Function && result(true);
				return;
			}
		}
		else
			if(needMic && Microphone.isSupported && Microphone.names.length > 0 )
			{
				const microphone:Microphone = Microphone.getMicrophone(mic);
				
				if(microphone && microphone.muted)
				{
					microphone.addEventListener(StatusEvent.STATUS, camStatusHandler);
					target = microphone;
					stream.attachAudio(microphone);
					stream.publish('devnull');
				}
				else{
					result && result is Function && result(true);
					return;
				}
			}
		
		if(Microphone.names.length > 0 || Camera.names.length > 0)
		{
			showSecurityPanel();
		}
		else
			fault && fault is Function && fault('not_supported');
		
		
		stage && setTimeout(stage.addEventListener,500,MouseEvent.MOUSE_MOVE, panelClosedHandler);
		
		function panelClosedHandler(e:MouseEvent):void{
			
			if (e.stageX >= 0 && e.stageX < stage.stageWidth && e.stageY >= 0 && e.stageY < stage.stageHeight){
				
				target && target.removeEventListener(StatusEvent.STATUS, camStatusHandler);
				stage.removeEventListener(MouseEvent.MOUSE_MOVE,panelClosedHandler);
				if(stream){
					stream.attachAudio(null);
					stream.attachCamera(null);
					stream.dispose();
				}
				if(video){
					video.attachCamera(null);
					video.clear();
				}
				video = null;
				target = null;
				if(status){
					debug('media_access success');
					result && result is Function && result(true);
				}else{
					debug('media_access fail');
					fault && fault is Function && fault('access_denied');
				}
			}
			
		}
		
		
		function camStatusHandler(e:StatusEvent):void
		{
			debug('media access camera status', e.code);
			if(e.code === "Camera.Unmuted" || e.code === "Microphone.Unmuted")
				status = true;
			else
				status = false;
		}
	}
}







import flash.system.Security;
import flash.system.SecurityPanel;

internal function showSecurityPanel():void
{
	Security.showSettings(SecurityPanel.PRIVACY);
}

