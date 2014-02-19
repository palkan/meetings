/**
 * User: palkan
 * Date: 5/29/13
 * Time: 12:34 PM
 */
package ru.teachbase.manage.session.model {
import ru.teachbase.components.notifications.Notification;
import ru.teachbase.events.GlobalEvent;
import ru.teachbase.model.*;
import ru.teachbase.tb_internal;
import ru.teachbase.utils.Arrays;
import ru.teachbase.utils.Configger;
import ru.teachbase.utils.shortcuts.config;
import ru.teachbase.utils.shortcuts.notify;
import ru.teachbase.utils.shortcuts.translate;


/**
 *
 * Current user model
 *
 * @inheritDoc
 *
 */

public class CurrentUser extends User {

    public var sharing:SharingModel = new SharingModel();
    public var settings:UserLocalSettings;

    private var _rtmpToken:String;

    private var _initialized:Boolean = false;

    /**
     * @inheritDoc
     */

    public function CurrentUser() {
        super();
    }

    /**
     * Create CurrentUser from User
     *
     * @param user
     */

    public function initialize(user:User):void{

        if(!user) return;

        id = user.id;
        sid = user.sid;
        avatarURL = user.avatarURL;
        name = user.name;
        suffix = user.suffix;
        fullName = user.fullName;
        _permissions = user.permissions;

        // if initialized - set other fields to defaults

        if(initialized){

            sharing.audioSharing = sharing.videoSharing = false;

            shareStatus = 0;
            requestStatus = 0;
            permissions = _permissions;

        }else{
            settings = new UserLocalSettings(config(Configger.COOKIE_NS));
        }

        _initialized = true;
    }

    /**
     *
     * Update permissions and send GlobalEvent.PERMISSIONS_UPDATE
     *
     * @param value
     */


    override public function set permissions(value:uint):void{
        const oldRole = role;

        super.permissions = value;



        GlobalEvent.dispatch(GlobalEvent.PERMISSIONS_UPDATE,value);

        if(role != oldRole) notify(new Notification(translate('role_changed','notifications')));

    }

    /**
     *
     * RTMP security token
     *
     */

    public function get rtmpToken():String {
        return _rtmpToken;
    }

    tb_internal function setRtmpToken(value:String):void {
        _rtmpToken = value;
    }



    public function get initialized():Boolean {
        return _initialized;
    }

}
}
