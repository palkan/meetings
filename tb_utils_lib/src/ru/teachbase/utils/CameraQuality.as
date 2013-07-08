/**
 * User: palkan
 * Date: 6/11/13
 * Time: 4:12 PM
 */
package ru.teachbase.utils {
import flash.media.Camera;

public class CameraQuality{

    public var quality:int;
    public var key_frame_interval:int;
    public var fps:int;
    public var width:int;
    public var height:int;
    public var bandwidth:int;

    function CameraQuality(quality:int,kfi:int,fps:int,width:int,height:int,bandwidth:int = 0){

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
}
