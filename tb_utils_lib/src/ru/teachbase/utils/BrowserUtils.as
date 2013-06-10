package ru.teachbase.utils {
import flash.external.ExternalInterface;

public class BrowserUtils {

    private static const BROWSER_INFO:String =
            '(function( ) {' +
                    'return { appName: navigator.appName, version:navigator.appVersion, userAgent:navigator.userAgent };' +
                    '})()';


    private static const CLOSE_WINDOW:String = "window.close()";
    private static const RELOAD_WINDOW:String = "window.location.reload()";


    /**
     *
     * @return Object({appName: navigator.appName, version:navigator.appVersion, userAgent:navigator.userAgent});
     */

    public static function getVersion():Object {
        if (!ExternalInterface.available) return null;

        return ExternalInterface.call(BROWSER_INFO);
    }

    public static function closeWindow():void {

        if (!ExternalInterface.available) return;

        ExternalInterface.call(CLOSE_WINDOW);

    }

    public static function reloadWindow():void {

        if (!ExternalInterface.available) return;

        ExternalInterface.call(RELOAD_WINDOW);

    }

}
}