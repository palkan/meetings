/**
 * User: palkan
 * Date: 5/29/13
 * Time: 1:07 PM
 */
package ru.teachbase.manage.session.model{
import ru.teachbase.constants.PublishQuality;
import ru.teachbase.utils.shortcuts.cookie;
import ru.teachbase.utils.shortcuts.debug;

/**
 *
 * User local settings (stored in Local SharedObjects or during Runtime)
 *
 * All properties are lower case because of local shared objects.
 *
 */

public class UserLocalSettings {

    public static const COLORS:Array = [0xCC3D33, 0x7220A3, 0x347B4D, 0xD67400];


    private var _color:uint = 0xCC3D33;
    private var _volumelevel:int = 80;
    private var _micid:int = -1;
    private var _miclevel:int = 80;
    private var _camid:String = null;
    private var _lang:String = "ru";
    private var _publishquality:String = PublishQuality.MEDIUM;
    private var _shownotifications:Boolean = true;
    private var _showcursor:Boolean = true;
    private var _receive_video:Boolean = true;


    /**
     *
     * @param defaults
     */

    public function UserLocalSettings(defaults:Object = null) {

        if(defaults){

            for(var key:String in defaults)
                hasOwnProperty(key) && (this["_"+key] = defaults[key]);

            publishquality = PublishQuality.MEDIUM;
        }

        debug("Cookies",defaults);
    }


    /**
     * @default 80
     */

    public function get miclevel():int {
        return _miclevel;
    }

    public function set miclevel(value:int):void {
        _miclevel = value;
        cookie('micLevel',value);
    }

    /**
     * @default null
     */

    public function get camid():String {
        return _camid;
    }

    public function set camid(value:String):void {
        _camid = value;
        cookie('camID',value);
    }

    /**
     * @default "medium"
     *
     * @see ru.teachbase.utils.CameraQuality
     */

    public function get publishquality():String {
        return _publishquality;
    }

    public function set publishquality(value:String):void {
        _publishquality = value;
       //Fixme: !!! cookie('publishQuality',value);
    }

    /**
     * @default "ru"
     */

    public function get lang():String {
        return _lang;
    }

    public function set lang(value:String):void {
        _lang = value;
        cookie('lang',value);
    }

    /**
     * @default 80
     */

    public function get volumelevel():int {
        return _volumelevel;
    }

    public function set volumelevel(value:int):void {
        _volumelevel = value;
        cookie('volumeLevel',value);
    }

    /**
     * @default -1
     */

    public function get micid():int {
        return _micid;
    }

    public function set micid(value:int):void {
        _micid = value;
        cookie('micID',value);
    }

    /**
     *  @default true
     */

    public function get shownotifications():Boolean {
        return _shownotifications;
    }

    public function set shownotifications(value:Boolean):void {
        _shownotifications = value;
        cookie('showNotifications',value);
    }

    public function get color():uint {
        return _color;
    }

    public function set color(value:uint):void {
        _color = value;
        cookie('color',value);
    }

    public function get showcursor():Boolean {
        return _showcursor;
    }

    public function set showcursor(value:Boolean):void {
        _showcursor = value;
        cookie('showcursor',value);
    }

    public function get receive_video():Boolean {
        return _receive_video;
    }

    public function set receive_video(value:Boolean):void {
        _receive_video = value;
    }
}
}
