/**
 * User: palkan
 * Date: 5/29/13
 * Time: 1:07 PM
 */
package ru.teachbase.model{

/**
 *
 * User local settings (stored in LocalSharedObjects or during Runtime)
 *
 */

public class UserLocalSettings {

    public var volume:int = 80;
    public var micID:int = -1;
    public var camID:String = null;
    public var lang:String;
    public var publishSettingsId;


    public function UserLocalSettings(defaults:Object = null) {

        if(defaults){

            for(var key:String in defaults)
                hasOwnProperty(key) && (this[key] = defaults[key]);

        }

    }


}
}
