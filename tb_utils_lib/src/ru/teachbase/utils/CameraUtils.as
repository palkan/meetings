/**
 * User: palkan
 * Date: 5/31/13
 * Time: 10:40 AM
 */
package ru.teachbase.utils {
import flash.media.Camera;

public class CameraUtils {

    private static var LOW_QUALITY:Quality = new Quality(60,10,15,160,120);

    private static var MEDIUM_QUALITY:Quality = new Quality(75,10,15,320,240);

    private static var HIGH_QUALITY:Quality = new Quality(90,10,15,480,360);

    public static function getCamera(id:String = null):Camera{

        var camera:Camera;

        camera = Camera.getCamera(id);
        if (!camera) {
            camera = Camera.getCamera();
        }

        return camera;
    }


    public static function setLowQuality(cam:Camera):Camera{
        return LOW_QUALITY.setup(cam);
    }

    public static function setMediumQuality(cam:Camera):Camera{
        return MEDIUM_QUALITY.setup(cam);
    }

    public static function setHighQuality(cam:Camera):Camera{
        return HIGH_QUALITY.setup(cam);
    }

}
}

import flash.media.Camera;

internal class Quality{

    public var quality:int;
    public var key_frame_interval:int;
    public var fps:int;
    public var width:int;
    public var height:int;
    public var bandwidth:int;

    function Quality(quality:int,kfi:int,fps:int,width:int,height:int,bandwidth:int = 0){

        this.quality = quality;
        this.key_frame_interval = kfi;
        this.fps = fps;
        this.width = width;
        this.height = height;
        this.bandwidth = bandwidth;

    }


    public function setup(cam:Camera):Camera{
        if(!cam) return null;

        cam.setKeyFrameInterval(key_frame_interval);
        cam.setMode(width,height,fps);
        cam.setQuality(bandwidth,quality);

        return cam;
    }
}