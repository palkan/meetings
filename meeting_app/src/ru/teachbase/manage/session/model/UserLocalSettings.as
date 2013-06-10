/**
 * User: palkan
 * Date: 5/29/13
 * Time: 1:07 PM
 */
package ru.teachbase.manage.session.model{
import ru.teachbase.utils.shortcuts.cookie;

/**
 *
 * User local settings (stored in LocalSharedObjects or during Runtime)
 *
 */

public class UserLocalSettings {

    private var _volumeLevel:int = 80;
    private var _micID:int = -1;
    private var _micLevel:int = 80;
    private var _camID:String = null;
    private var _lang:String = "ru";
    private var _publishQuality:String = "medium";


    public function UserLocalSettings(defaults:Object = null) {

        if(defaults){

            for(var key:String in defaults)
                hasOwnProperty(key) && (this["_"+key] = defaults[key]);

        }

    }


    public function get micLevel():int {
        return _micLevel;
    }

    public function set micLevel(value:int):void {
        _micLevel = value;
        cookie('micLevel',value);
    }

    public function get camID():String {
        return _camID;
    }

    public function set camID(value:String):void {
        _camID = value;
        cookie('camID',value);
    }

    public function get publishQuality():String {
        return _publishQuality;
    }

    public function set publishQuality(value:String):void {
        _publishQuality = value;
        cookie('publishQuality',value);
    }

    public function get lang():String {
        return _lang;
    }

    public function set lang(value:String):void {
        _lang = value;
        cookie('lang',value);
    }

    public function get volumeLevel():int {
        return _volumeLevel;
    }

    public function set volumeLevel(value:int):void {
        _volumeLevel = value;
        cookie('volumeLevel',value);
    }

    public function get micID():int {
        return _micID;
    }

    public function set micID(value:int):void {
        _micID = value;
        cookie('micID',value);
    }
}
}
