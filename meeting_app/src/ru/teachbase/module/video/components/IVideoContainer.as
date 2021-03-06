package ru.teachbase.module.video.components
{
import flash.display.Stage;
import flash.media.Camera;
import flash.net.NetStream;

import mx.core.IVisualElement;

public interface IVideoContainer extends IVisualElement
	{
		
		function get from():Number;
		function get stage():Stage;
		function get camera():Camera;
        function get stream():NetStream;
		function set camera(cam:Camera):void;
		function set isAdmin(value:Boolean):void;
		
		function rotateVideo(rotation:int):void;
		
	}
}