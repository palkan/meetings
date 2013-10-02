package ru.teachbase.manage.session.model {
import flash.utils.Dictionary;

import mx.collections.ArrayCollection;
import mx.events.CollectionEvent;

import ru.teachbase.components.notifications.Notification;

import ru.teachbase.manage.modules.model.ModuleInstanceData;

import ru.teachbase.model.*;
import ru.teachbase.tb_internal;
import ru.teachbase.utils.Permissions;
import ru.teachbase.utils.helpers.lambda;
import ru.teachbase.utils.shortcuts.notify;
import ru.teachbase.utils.shortcuts.translate;

use namespace tb_internal;

/**
 * @author Teachbase (created: Apr 26, 2012)
 */

public class Meeting{

    /**
     * Meeting id
     */

    public var id:int;

    /**
     * Meeting title
     */

    public var title:String;


    /**
     *
     *  Meeting URL
     */

    public var url:String;

    /**
     * <id:int> = instance of User
     */

    public var usersByID:Object = {};

    /**
     *  Meeting users collection
     *
     *  @see User
     */

    public const usersList:ArrayCollection = new ArrayCollection();

    /**
     * Meeting streams collection
     *
     * @see StreamData
     */

    public const streamList:ArrayCollection = new ArrayCollection();


    /**
     *  Meeting streams by name
     *
     */

    public var streamsByName:Object = {};

    /**
     * Initialized modules
     *
     * moduleId => module
     * Module => module
     */

    public const modules:Dictionary = new Dictionary(true);

    /**
     * Initialized modules
     */

    public const modulesCollection:ArrayCollection = new ArrayCollection();

    /**
     *
     */

    public const docsById:Object = {};

    /**
     *
     */

    public const docsCollection:ArrayCollection = new ArrayCollection();

    /**
     * Module instances collection
     */

    public const instances:Vector.<ModuleInstanceData> = new <ModuleInstanceData>[];

    /**
     * moduleId:instanceId => ModuleInstanceData
     */
    public var instancesById:Object = {};

    /**
     * LIVE or RECORD
     *
     * @see MeetingState
     */

    private var _state:uint;


    /**
     * @see MeetingSettings
     */

    private var _settings:uint;

    //------------ constructor ------------//

    public function Meeting() {

    }


    //------------ API -----------------//

    public function addUser(usr:User):Boolean {

        if (usersByID[usr.sid] != undefined)
            return false;

        usersList.addItem(usr);
        usersByID[usr.sid] = usr;
        return true;
    }


    public function removeUser(sid:Number):User {

        if (usersByID[sid] == undefined)
            return null;

        const usr:User = usersByID[sid];

        usersList.removeItemAt(usersList.getItemIndex(usersByID[sid]));
        usersByID[sid] = undefined;
        return usr;
    }


    public function updateUser(sid:Number, property:String, value:*):Boolean {

        if (usersByID[sid] == undefined)
            return false;

        var usr:User = usersByID[sid];

        if (!usr.hasOwnProperty(property))
            return false;

        if (usr[property] == value)
            return false;

        var oldRequestStatus:int = usr.requestStatus;

        usr[property] = value;


        if(App.user.sid == usr.sid) App.user[property] = value;
        else
        if (App.user.role == "admin" && property == "requestStatus")
            handleRequestStatusChange(usr, oldRequestStatus);

        usersList.dispatchEvent(new CollectionEvent(CollectionEvent.COLLECTION_CHANGE));
        return true;
    }

    //------------- handlers -------------------//


    private function handleRequestStatusChange(usr:User, oldValue:uint):void {
        if (oldValue > usr.requestStatus)   return;

        const reqId:uint = usr.requestStatus - oldValue;
        var message:String='';

        switch(reqId){
            case Permissions.CAMERA:
                message = translate('req_cam','notifications',usr.extName);
                break;
            case Permissions.MIC:
                message = translate('req_mic','notifications',usr.extName);
                break;
            case Permissions.DOCS:
                message = translate('req_doc','notifications',usr.extName);
                break;
        }

        notify(new Notification(
                message,
                null,
                translate('Accept'),
                lambda(App.session.setUserRights, usr.sid, reqId,true),
                translate('Decline'),
                lambda(App.session.setRequest,reqId,false,usr.sid)
        ));
    }

    //------------ get / set -------------//

    public function set users(value:Array):void {
        usersList.source = value;

        usersByID = {};

        for each (var usr:User in value)
            usersByID[usr.sid] = usr;

    }

    /**
     * @see ru.teachbase.manage.session.model.MeetingState
     */

    public function get state():uint {
        return _state;
    }

    tb_internal function setState(value:uint):void{
        _state = value;
    }

    /**
     * @see ru.teachbase.manage.session.model.MeetingSettings
     */

    public function get settings():uint {
        return _settings;
    }

    tb_internal function setSettings(value:uint):void{

        _settings = value;
    }
}
}
