/**
 * User: palkan
 * Date: 8/7/13
 * Time: 12:46 PM
 */
package ru.teachbase.components.callouts {
import flash.display.DisplayObjectContainer;

/**
 *
 * Shared confirm callout.
 *
 * Uses ConfirmCalloutInstance as View.
 *
 */


public class ColorPickerCallout {

    private static const instance:ColorPickerInstance = new ColorPickerInstance();

    /**
     *
     * @param target
     * @param colors Array of colors as uints
     * @param callbackFunction
     */

    public static function open(target:DisplayObjectContainer, colors:Array, callbackFunction:Function=null):void {

        instance.dataProvider = colors;
        instance.callbackFunction = callbackFunction;

        instance.open(target);

    }

    /**
     *
     */

    public static function close():void {

        instance.callbackFunction = null;
        instance.close();

    }

}
}
