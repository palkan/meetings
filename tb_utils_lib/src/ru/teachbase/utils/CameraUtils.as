/**
 * User: palkan
 * Date: 5/31/13
 * Time: 10:40 AM
 */
package ru.teachbase.utils {
import flash.media.Camera;

public class CameraUtils {

    private static var LOW_QUALITY:CameraQuality = new CameraQuality(60,10,15,160,120);

    private static var MEDIUM_QUALITY:CameraQuality  = new CameraQuality (75,10,15,320,240);

    private static var HIGH_QUALITY:CameraQuality  = new CameraQuality (90,10,15,480,360);

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

