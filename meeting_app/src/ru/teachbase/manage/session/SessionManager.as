package ru.teachbase.manage.session {
import mx.rpc.Responder;

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
import ru.teachbase.utils.shortcuts.rtmp_call;
import ru.teachbase.utils.shortcuts.rtmp_history;
import ru.teachbase.utils.shortcuts.warning;

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

    override protected function initialize():void {
        if (initialized)
            return;

        // register classes

        new UserChangeData();
        new User();

        _model = App.meeting;

        if (config('user_id') && config('meeting_id')) {
            login(config('meeting_id'), config('user_id'));
        } else if (config('auth_hash')) {
            loginByHash(config('auth_hash'));
        } else
            _failed = true;
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
        App.rtmp.callServer("login", new Responder(loginSuccess, loginError), user_id, meeting_id);

    }

    /**
     *
     * login by hash (as authorized user or guest).
     *
     * Hash is a key to record in Redis (for example) where all other data is stored.
     *
     * @param hash
     */

    public function loginByHash(hash:String):void {
        //TODO
    }

    /**
     *
     * Login by session_id (e.g. after reconnect)
     *
     * @param sid
     */


    public function loginBySessionId(sid:Number = 0):void {
        !sid && (sid = App.user.sid);
        //TODO
    }


    /**
     * Start meeting recording
     */

    public function startRecord():void {

        if (_model.state == MeetingState.RECORD || !(_model.settings & MeetingSettings.RECORD) || !App.user.isAdmin()) return;

        function success(...args):void {

            _model.state = MeetingState.RECORD;

        }

        function error(...args):void {
        }

        rtmp_call("start_record", new Responder(success, error));

    }

    /**
     * Stop meeting recording
     */

    public function stopRecord():void {

        if (_model.state == MeetingState.LIVE || !(_model.settings & MeetingSettings.RECORD) || !App.user.isAdmin()) return;


        function success(...args):void {
            _model.state = MeetingState.LIVE;
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

        rtmp_call("set_role", null, sid, role);
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
        if (!id && App.user.isAdmin()) id = App.user.sid;

        var _usr:User = App.meeting.usersByID[id] as User;

        if (!_usr || Permissions.hasRight(value, _usr.requestStatus) == flag)
            return;

        value = _usr.requestStatus + (flag ? value : -value);

        rtmp_call("request_status", null, _usr.sid, value);
    }

    /**
     * Call this function to add or cancel user's rights (permissions).
     *
     * @param sid user session id
     * @param rights permission mask (use Permissions class constants)
     * @param flag to cancel permission set to <i>false</i>
     *
     */

    public function setUserRights(sid:Number, rights:uint, flag:Boolean = true):void {
        if (!App.user.isAdmin()) return;

        var _usr:User = App.meeting.usersByID[sid] as User;

        if (!_usr || Permissions.hasRight(rights, _usr.shareRights) == flag)
            return;

        if (flag && rights === Permissions.CAMERA && !Permissions.hasRight(Permissions.MIC, _usr.shareRights))
            rights += Permissions.MIC;

        rights = _usr.shareRights + (flag ? rights : -rights);

        rtmp_call("set_rights", null, sid, rights);
    }


    //------------------ API ------------------//


    private function loginSuccess(args:Array):void {

        // initialize current user
        App.user.initialize(args[1] as User);

        // set rtmp token
        App.user.tb_internal::rtmpToken = args[0];

        _onAfterLogin && _onAfterLogin();
    }

    private function loginError(error:*):void {
        warning('Login failed', error);
        _failed = true;
    }

    private function loadMeetingModel():void {
        users_listener.initialize();
        meeting_listener.initialize();
        users_listener.addEventListener(RTMPEvent.DATA, usersChangeHandler);
        meeting_listener.addEventListener(RTMPEvent.DATA, meetingUpdateHandler);
        rtmp_history("meeting", new Responder(handleHistory, historyFailed));
    }

    protected function usersChangeHandler(e:RTMPEvent):void {
        var data:UserChangeData = e.packet.data as UserChangeData;
        if (!data) return;

        switch (data.type) {
            case "userJoin":
                _model.addUser(data.value) && GlobalEvent.dispatch(GlobalEvent.USER_ADD, _model.usersByID[(data.value as User).sid]);
                break;
            case "userLeave":
                _model.removeUser(data.id) && GlobalEvent.dispatch(GlobalEvent.USER_LEAVE, data.value);
                break;
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
                _model.settings = data.value;
                GlobalEvent.dispatch(GlobalEvent.MEETING_SETTINGS_UPDATE, _model.settings);
                break;
            case "state":
                _model.state = data.value;
                GlobalEvent.dispatch(GlobalEvent.MEETING_STATE_UPDATE, _model.state);
                break;
        }
    }

    private function historyFailed(error:*):void {
        warning('Failed to load history', error);
        _failed = true;
    }


    private function handleHistory(meeting_model:Object):void {

        _model.users = getValue(meeting_model, "users", [], isArray);

        _model.state = getValue(meeting_model, "state", MeetingState.LIVE);
        _model.settings = getValue(meeting_model, "settings", 0);

        meeting_listener.readyToReceive = users_listener.readyToReceive = true;

        _initialized = true;

    }

    override public function dispose():void {
        users_listener.dispose();
        meeting_listener.dispose();

        // clean model only if it is registered manager
        __registered && (_model.usersList.length = 0);
        __registered && (_model.usersByID = {});

        _initialized = false;
    }


}
}

