package ru.teachbase.manage.session {
import mx.rpc.Responder;

import ru.teachbase.components.notifications.Notification;
import ru.teachbase.constants.ErrorCodes;
import ru.teachbase.constants.PacketType;
import ru.teachbase.events.GlobalEvent;
import ru.teachbase.manage.*;
import ru.teachbase.manage.rtmp.RTMPListener;
import ru.teachbase.manage.rtmp.RTMPManager;
import ru.teachbase.manage.rtmp.events.RTMPEvent;
import ru.teachbase.manage.session.model.Meeting;
import ru.teachbase.manage.session.model.MeetingSettings;
import ru.teachbase.manage.session.model.MeetingState;
import ru.teachbase.manage.session.model.MeetingUpdateData;
import ru.teachbase.manage.session.model.UserChangeData;
import ru.teachbase.model.App;
import ru.teachbase.model.User;
import ru.teachbase.tb_internal;
import ru.teachbase.utils.Permissions;
import ru.teachbase.utils.helpers.getValue;
import ru.teachbase.utils.helpers.isArray;
import ru.teachbase.utils.shortcuts.config;
import ru.teachbase.utils.shortcuts.error;
import ru.teachbase.utils.shortcuts.notify;
import ru.teachbase.utils.shortcuts.rtmp_call;
import ru.teachbase.utils.shortcuts.rtmp_history;
import ru.teachbase.utils.shortcuts.translate;

use namespace tb_internal;

/**
 * @author Teachbase (created: Jul 5, 2012; updated: May 31, 2013)
 */
public final class SessionManager extends Manager {
    private const users_listener:RTMPListener = new RTMPListener(PacketType.USERS);
    private const meeting_listener:RTMPListener = new RTMPListener(PacketType.MEETING);


    private var _model:Meeting;
    private var _onAfterLogin:Function;
    //------------ constructor ------------//

    public function SessionManager(register:Boolean = false) {
        super(register, [RTMPManager]);
    }

    //------------ initialize ------------//

    override protected function initialize(reinit:Boolean = false):void {
        if (initialized)
            return;

        if (reinit) {
            reinitialize();
            return;
        }

        // register classes

        new UserChangeData();
        new MeetingUpdateData();
        new User();

        _model = App.meeting;

        if (config('user_id') && config('meeting_id')) {
            login(config('meeting_id'), config('user_id'));
        } else if (config('auth_hash') && config('meeting_id')) {
            loginByHash(config('auth_hash'), config('meeting_id'));
        } else {
            error("Missing login parameters");
            _failed = true;
        }
    }


    protected function reinitialize():void {

        loginBySessionId(App.meeting.id, App.user.sid);
    }


    override public function clear():void {
        super.clear();

        App.user.shareStatus = 0;

        App.meeting.tb_internal::setState(MeetingState.LIVE);

        users_listener.dispose();
        meeting_listener.dispose();
        users_listener.removeEventListener(RTMPEvent.DATA, usersChangeHandler);
        meeting_listener.removeEventListener(RTMPEvent.DATA, meetingUpdateHandler);

    }


    //---------------- API -----------------//

    /**
     *
     * Login by user id and meeting id.
     *
     * For authorized users only
     *
     * @param meeting_id
     * @param user_id
     */

    public function login(meeting_id:uint, user_id:uint):void {

        _onAfterLogin = loadMeetingModel;
        App.meeting.id = meeting_id;
        App.rtmp.callServer("tb_login", new Responder(loginSuccess, loginError), user_id, meeting_id);

    }

    /**
     *
     * login by hash (as authorized user or guest).
     *
     * @param hash
     * @param meeting_id
     */

    public function loginByHash(hash:String, meeting_id:uint):void {
        _onAfterLogin = loadMeetingModel;
        App.meeting.id = meeting_id;
        App.rtmp.callServer("tb_login_by_hash", new Responder(loginSuccess, loginError), hash, meeting_id);
    }

    /**
     *
     * Login by session_id (e.g. after reconnect)
     *
     * @param sid
     * @param meeting_id
     */


    public function loginBySessionId(meeting_id:uint, sid:Number = 0):void {
        !sid && (sid = App.user.sid);

        _onAfterLogin = loadMeetingModel;

        App.rtmp.callServer("tb_login_by_sid", new Responder(loginSuccess, loginError), sid, meeting_id);
    }


    /**
     *
     */

    public function toggleRecording():void{

        if (!(_model.settings & MeetingSettings.RECORD) || !App.user.isAdmin()) return;

        if (_model.state == MeetingState.LIVE) startRecord();
        else stopRecord();

    }


    /**
     * Start meeting recording
     */

    private function startRecord():void {

        function success(...args):void {

            //_model.tb_internal::setState(MeetingState.RECORD);

        }

        function error(...args):void {
        }

        rtmp_call("start_record", new Responder(success, error));

    }

    /**
     * Stop meeting recording
     */

    private function stopRecord():void {

        function success(...args):void {
            //_model.tb_internal::setState(MeetingState.LIVE);
        }

        function error(...args):void {
        }

        rtmp_call("stop_record", new Responder(success, error));

    }


    /**
     * Call this function to notify other users about a new user joined
     *
     *
     */


    public function userReady():void {
        rtmp_call("user_ready", null, App.user.sid);
    }

    /**
     * Call this function to change user role.
     *
     *
     * @param sid user session id
     * @param role new user role
     *
     */

    public function setUserRole(sid:Number, role:String):void {

        if (!App.meeting.usersByID[sid] || !App.user.isAdmin()) return;

        var permissions:uint;
        const user:User = App.meeting.usersByID[sid];

        if (role == "admin")  permissions = user.permissions | Permissions.ADMIN_MASK;
        else if (role == "user") permissions = user.permissions ^ Permissions.ADMIN_MASK;
        else return;

        rtmp_call("set_permissions", null, sid, permissions);
    }

    /**
     * @param type Request type as uint code (@see Permissions)
     */

    public function toggleRequest(type:uint):void {

        var flag:Boolean = !Permissions.hasRight(type, App.user.requestStatus);

        setRequest(type, flag);

    }

    /**
     * Call this function to make permission request or cancel existing one.
     *
     * @param value permission mask (use Permissions class constants)
     * @param flag  to cancel request set <i>flag</i> to <i>false</i>
     * @param id User id (use when you want to change requestStatus of another user)
     *
     */


    public function setRequest(value:uint, flag:Boolean = true, id:Number = 0):void {
        if (!id && !App.user.isAdmin()) id = App.user.sid;

        var _usr:User = App.meeting.usersByID[id] as User;

        if (!_usr || Permissions.hasRight(value, _usr.requestStatus) == flag)
            return;

        value = _usr.requestStatus + (flag ? value : -value);

        rtmp_call("request_status", null, _usr.sid, value);
    }


    /**
     * Call this function to set current user's shareStatus
     *
     * @param value permission mask (use Permissions class constants)
     *
     */


    public function setShareStatus(value:uint):void {
        rtmp_call("share_status", null, App.user.sid, value);
    }

    /**
     * Call this function to add or cancel user's rights (share permissions).
     *
     * @param sid user session id
     * @param rights right bit mask
     * @param flag to cancel permission set to <code>false</code>
     *
     * @see ru.teachbase.utils.Permissions
     */

    public function setUserRights(sid:Number, rights:uint, flag:Boolean = true):void {
        if (!App.user.isAdmin()) return;

        var _usr:User = App.meeting.usersByID[sid] as User;

        // check if we have the user and the user has no such rights

        if (!_usr || Permissions.hasRight(rights, _usr.permissions) == flag)
            return;


        if (flag && rights === Permissions.CAMERA && !Permissions.micAvailable(_usr.permissions))
            rights += Permissions.MIC;

        rights = _usr.permissions + (flag ? rights : -rights);

        rtmp_call("set_permissions", null, sid, rights);
    }

    /**
     * Kick off user from meeting room.
     *
     * @param sid
     */


    public function kickOff(sid:Number):void {

        if (!App.user.isAdmin()) return;

        rtmp_call("kick_off_user", null, sid);
    }


    /**
     *
     * Activate (<code>flag == true</code>) or deactivate (<code>flag == false</code>) meeting option with code <code>code</code>
     *
     * @param code
     * @param flag
     */


    public function updateMeetingSettings(code:uint, flag:Boolean = true):void {

        if (!App.user.isAdmin()) return;

        if (Boolean(_model.settings & code) == flag) return;

        const newSettings:uint = _model.settings + (flag ? code : -code);

        rtmp_call("meeting_settings", null, newSettings);

    }


    //------------------ API ------------------//


    private function loginSuccess(args:Array):void {

        // initialize current user
        App.user.initialize(args[1] as User);

        // set rtmp token
        App.user.tb_internal::setRtmpToken(args[0]);

        _onAfterLogin && _onAfterLogin();
    }


    private function loginError(err:*):void {
        error('Login failed', err.hasOwnProperty('errorId') ? uint(err.errorId) : ErrorCodes.AUTHORIZATION_FAILED);
        _failed = true;
    }

    private function loadMeetingModel():void {
        users_listener.initialize();
        meeting_listener.initialize();
        users_listener.addEventListener(RTMPEvent.DATA, usersChangeHandler);
        meeting_listener.addEventListener(RTMPEvent.DATA, meetingUpdateHandler);
        rtmp_history(PacketType.MEETING, new Responder(handleHistory, historyFailed));
    }

    protected function usersChangeHandler(e:RTMPEvent):void {
        var data:UserChangeData = e.packet.data as UserChangeData;
        if (!data) return;

        switch (data.type) {
            case "userJoin":
                if (_model.addUser(data.value)) {
                    GlobalEvent.dispatch(GlobalEvent.USER_JOIN, _model.usersByID[(data.value as User).sid]);
                    notify(new Notification(translate('enter_room', 'notifications', [(data.value as User).fullName])));
                }
                break;
            case "userLeave":
            {
                var user:User = _model.removeUser(data.id);
                if (user) {
                    GlobalEvent.dispatch(GlobalEvent.USER_LEAVE, user);
                    notify(new Notification(translate('leave_room', 'notifications', [user.fullName])));
                }
                break;
            }
            case "userChange":
                _model.updateUser(data.id, data.property, data.value);
                break;
        }
    }

    protected function meetingUpdateHandler(e:RTMPEvent):void {

        var data:MeetingUpdateData = e.packet.data as MeetingUpdateData;
        if (!data) return;

        switch (data.type) {
            case "settings":
                _model.tb_internal::setSettings(data.value);
                GlobalEvent.dispatch(GlobalEvent.MEETING_SETTINGS_UPDATE, _model.settings);

                // update current user model if we affected request settings

                !(data.value & MeetingSettings.MAKE_REQUEST) && App.user.requestStatus > 0 && setRequest(App.user.requestStatus,false);

                break;
            case "state":
                _model.tb_internal::setState(data.value);
                notify(new Notification(_model.state == MeetingState.LIVE ? translate('stop_rec', 'notifications') : translate('start_rec', 'notifications')));
                GlobalEvent.dispatch(GlobalEvent.MEETING_STATE_UPDATE, _model.state);
                break;
        }
    }

    private function historyFailed(err:*):void {
        error('Failed to load session history');
        _failed = true;
    }


    private function handleHistory(meeting_model:Object):void {

        _model.users = getValue(meeting_model, "users", [], isArray);

        _model.usersByID[App.user.sid] && ((_model.usersByID[App.user.sid] as User).iam = true);

        _model.tb_internal::setState(getValue(meeting_model, "state", MeetingState.LIVE));
        _model.tb_internal::setSettings(getValue(meeting_model, "settings", 0));

        meeting_listener.readyToReceive = users_listener.readyToReceive = true;

        _initialized = true;

    }

    override public function dispose():void {
        users_listener.dispose();
        meeting_listener.dispose();

        // clean model only if it is registered manager
        __registered && (_model.usersList.removeAll());
        __registered && (_model.usersByID = {});

        _initialized = false;
    }


}
}

