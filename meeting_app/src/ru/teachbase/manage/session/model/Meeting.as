package ru.teachbase.manage.session.model {
import flash.utils.Dictionary;

import mx.collections.ArrayCollection;
import mx.events.CollectionEvent;

import ru.teachbase.manage.modules.model.ModuleInstanceData;

import ru.teachbase.model.*;
import ru.teachbase.tb_internal;

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


    public function removeUser(sid:Number):Boolean {

        if (usersByID[sid] == undefined)
            return false;

        usersList.removeItemAt(usersList.getItemIndex(usersByID[sid]));
        usersByID[sid] = undefined;
        return true;
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

    //------------- API -------------------//


    private function handleRequestStatusChange(usr:User, oldValue:uint):void {
        if (oldValue > usr.requestStatus)   return;
        //TODO: notification notify(NotificationTypes.PERMISSION_NOTIFICATION, String(usr.requestStatus - oldValue), usr);
    }

    //------------ get / set -------------//

    public function set users(value:Array):void {
        usersList.source = value;

        for each (var usr:User in value)
            usersByID[usr.sid] = usr;

    }

    public function get state():uint {
        return _state;
    }

    tb_internal function set state(value:uint):void{

    }

    public function get settings():uint {
        return _settings;
    }

    tb_internal function set settings(value:uint):void{

    }
}
}
