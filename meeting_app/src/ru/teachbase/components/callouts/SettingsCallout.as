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


public class SettingsCallout {

    private static const instance:SettingsCalloutInstance = new SettingsCalloutInstance();

    /**
     *
     * @param target
     * @param data
     */

    public static function open(target:DisplayObjectContainer, data:Vector.<SettingsItem>):void {

        instance.dataProvider = data;
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
