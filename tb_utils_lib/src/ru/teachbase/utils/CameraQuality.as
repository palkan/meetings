/**
 * User: palkan
 * Date: 6/11/13
 * Time: 4:12 PM
 */
package ru.teachbase.utils {
import flash.media.Camera;

public class CameraQuality{

    private var _id:String;
    private var _quality:int;
    private var _key_frame_interval:int;
    private var _fps:int;
    private var _width:int;
    private var _height:int;
    private var _bandwidth:int;
    private var _bitrate:int;


    /**
     *
     * @param id
     * @param quality
     * @param kfi
     * @param fps
     * @param width
     * @param height
     * @param bandwidth
     * @param bitrate
     */

    function CameraQuality(id:String,quality:int,kfi:int,fps:int,width:int,height:int,bandwidth:int = 0, bitrate:int = 0){

        this._id = id;
        this._quality = quality;
        this._key_frame_interval = kfi;
        this._fps = fps;
        this._width = width;
        this._height = height;
        this._bandwidth = bandwidth;
        this._bitrate = bitrate;

    }


    public function setup(cam:Camera):Camera{
        if(!cam) return null;

        cam.setKeyFrameInterval(_key_frame_interval);
        cam.setMode(_width,_height,_fps);
        cam.setQuality(_bandwidth,_quality);

        return cam;
    }





    public function get bandwidth():int {
        return _bandwidth;
    }

    public function get width():int {
        return _width;
    }

    public function get quality():int {
        return _quality;
    }

    public function get id():String {
        return _id;
    }

    public function get bitrate():int {
        return _bitrate;
    }

    public function get fps():int {
        return _fps;
    }

    public function get height():int {
        return _height;
    }

    public function get key_frame_interval():int {
        return _key_frame_interval;
    }
}
}
