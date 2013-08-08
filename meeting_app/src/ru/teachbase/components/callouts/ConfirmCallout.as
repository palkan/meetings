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


public class ConfirmCallout {

    private static const instance:ConfirmCalloutInstance = new ConfirmCalloutInstance();

    /**
     *
     * @param target
     * @param message
     * @param submitLabel
     * @param cancelLabel
     * @param submitFunction
     * @param cancelFunction
     */

    public static function open(target:DisplayObjectContainer, message:String, submitLabel:String, cancelLabel:String, submitFunction:Function, cancelFunction:Function = null):void {

        instance.message = message;
        instance.submitLabel = submitLabel;
        instance.cancelLabel = cancelLabel;
        instance.cancelFunction = cancelFunction;
        instance.submitFunction = submitFunction;

        instance.open(target);

    }

    /**
     *
     */

    public static function close():void {

        instance.close();

    }

}
}
