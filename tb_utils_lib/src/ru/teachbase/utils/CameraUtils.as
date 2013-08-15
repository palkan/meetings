/**
 * User: palkan
 * Date: 5/31/13
 * Time: 10:40 AM
 */
package ru.teachbase.utils {
import flash.media.Camera;

import ru.teachbase.constants.PublishQuality;

public class CameraUtils {

    public static const DEFAULT_FPS:int = 15;

    private static var LOW_QUALITY:CameraQuality = new CameraQuality(PublishQuality.LOW, 90, 10, DEFAULT_FPS, 160, 120, 0, 190);

    private static var MEDIUM_QUALITY:CameraQuality = new CameraQuality(PublishQuality.MEDIUM, 80, 10, DEFAULT_FPS, 320, 240, 0, 300);

    private static var HIGH_QUALITY:CameraQuality = new CameraQuality(PublishQuality.HIGH, 90, 10, DEFAULT_FPS, 480, 360, 0, 700);

    public static const AVAILABLE_QUALITIES:Array = [LOW_QUALITY, MEDIUM_QUALITY, HIGH_QUALITY];

    public static function getCamera(id:String = null):Camera {

        var camera:Camera;

        camera = Camera.getCamera(id);
        if (!camera) {
            camera = Camera.getCamera();
        }

        return camera;
    }


    public static function setLowQuality(cam:Camera):Camera {
        return LOW_QUALITY.setup(cam);
    }

    public static function setMediumQuality(cam:Camera):Camera {
        return MEDIUM_QUALITY.setup(cam);
    }

    public static function setHighQuality(cam:Camera):Camera {
        return HIGH_QUALITY.setup(cam);
    }


    /**
     *
     * @param bitrate
     */

    public static function getMaxAvailableQuality(bitrate:Number):CameraQuality {

        const size:int = AVAILABLE_QUALITIES.length;

        var i:int = 0;

        for (i; i < size; i++) {

            if (AVAILABLE_QUALITIES[i].bitrate > bitrate) break;

        }

        return i? AVAILABLE_QUALITIES[i-1] : null;

    }

}
}

