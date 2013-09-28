/**
 * User: palkan
 * Date: 8/21/13
 * Time: 2:59 PM
 */
package ru.teachbase.utils.interfaces {
import flash.display.BitmapData;
import flash.display.DisplayObject;

public interface ISkinAsset {
    /**
     * Return Sprite containing this Bitmap.
     */
    function toDisplayObject():DisplayObject;
    /**
     * Return this <code>bitmapData</code>.
     */
    function toBitmapData():BitmapData;

}
}
