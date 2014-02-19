package ru.teachbase.model {
import flash.events.EventDispatcher;

import ru.teachbase.constants.UserRoles;
import ru.teachbase.events.ChangeEvent;
import ru.teachbase.utils.Permissions;
import ru.teachbase.utils.system.registerClazzAlias;

registerClazzAlias(User);

/**
 *  Dispatched when some of the properties below is changed:
 *  <code>shareStatus, requestStatus, permissions, role</code>
 *
 *  @eventType ru.teachbase.events.ChangeEvent.CHANGED
 */

[Event(type="ru.teachbase.events.ChangeEvent", name="tb:changed")]


/**
 * Class representing user model.
 */

public class User extends EventDispatcher{


    /**
     * Teachbase user id
     *
     * @default null
     */

    public var id:int;

    /**
     *  RTMP session id
     *
     *  @default null
     */


    /**
     * Unique guest id
     */

    public var guest_id:String;

    /**
     *
     * Erlyvideo unique session id.
     *
     */

    public var sid:Number;

    /**
     *
     * Previous session id or 0 if doesn't exist.
     *
     */

    public var old_sid:Number;

    /**
     *  User name
     *
     *   @default null
     */

    public var name:String;

    /**
     * User full name
     *
     *  @default null
     */

    public var fullName:String;

    /**
     *
     * User's full name suffix (if there are several users with identical full names)
     *
     *  @default null
     */

    public var suffix:int;

    /**
     * User's avatar URL
     *
     *  @default null
     */

    public var avatarURL:String;


    /**
     * E-mail
     */

    public var email:String;


    /**
     * Is <code>true</code> iff this is a current user
     *
     *  @default null
     */

    public var iam:Boolean = false;

    protected var _shareStatus:uint;

    protected var _requestStatus:uint = 0;

    protected var _permissions:uint = 0;

    //------------ constructor ------------//


    /**
     * Create new user model
     */

    public function User() {
    }


    //------------ initialize ------------//

    //--------------- ctrl ---------------//

    /**
     *
     * @return <code>true</code> if User is administrator
     */

    public function isAdmin():Boolean {
        return Permissions.isAdmin(_permissions);
    }

    /**
     *
     * @return
     */

    public function toCSVString():String{

        return fullName + ';'+id+';'+role+';'+email;

    }

    //------------ get / set -------------//


    /**
     * User's role ("admin" or "user") as String
     */

    public function get role():String {
        return isAdmin() ? UserRoles.ADMIN : UserRoles.USER;
    }

    /**
     * Get fullname with suffix (if exists)
     */

    public function get extName():String{

        return suffix ? fullName+' '+(suffix+1) : fullName;

    }


    /**
     * Define whether user share cam|mic|doc (using Permissions bitmask)
     * @default null
     * @see ru.teachbase.utils.Permissions
     */
    public function get shareStatus():uint {
        return _shareStatus;
    }

    public function set shareStatus(value:uint):void {
        var _old:uint = _shareStatus;
        _shareStatus = value;
        dispatchEvent(new ChangeEvent(this,"shareStatus",value,_old));
    }

    /**
     * Define whether user requests cam|mic|doc (using Permissions bitmask)
     *
     * @default null
     * @see ru.teachbase.utils.Permissions
     */

    public function get requestStatus():uint {
        return _requestStatus;
    }

    public function set requestStatus(value:uint):void {
        var _old:uint = _requestStatus;
        _requestStatus = value;
        dispatchEvent(new ChangeEvent(this,"requestStatus",value,_old));
    }

    /**
     * User's rights: guest|role|cam|mic|doc, e.g. <i>admin</i> always has 2#*1111 (15).
     * User can have 2#10010 (2) - only mic available and guest.
     * @default null
     * @see ru.teachbase.utils.Permissions
     */

    public function get permissions():uint {
        return _permissions;
    }

    public function set permissions(value:uint):void {
        var _old:uint = _permissions;

        // check if we requested some rights and cancel request status

        if((value & _requestStatus)>0) requestStatus = 0;

        _permissions = value;
        dispatchEvent(new ChangeEvent(this,"permissions",value,_old));
    }
}
}
