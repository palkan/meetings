package ru.teachbase.module.chat.model {
import mx.collections.ArrayCollection;
import mx.collections.CursorBookmark;

public class ChatRoom {

    private var _messages:ArrayCollection;
    private var _roomId:Number;
    private var _roomName:String;
    private var _unreadMessages:int = 0;
    private var _totalMessages:int = 0;
    private var _active:Boolean = true;
    private var _visible:Boolean = false;

    private var _system:Boolean;

    /**
     * Creates new chat room
     *
     * @param id
     * @param name
     * @param system Define whether current room is system (public chat or admins chat).
     */

    public function ChatRoom(id:Number, name:String, system:Boolean = false) {
        _roomId = id;
        _roomName = name;
        _system = system;
        _messages = new ArrayCollection();
    }

    /**
     * Add new message to room.
     *
     * @param message
     */

    public function add(message:ChatMessage):void{

        _totalMessages++;

        if(!_visible) _unreadMessages++;

        _messages.addItem(message);
    }

    /**
     *
     * Remove all messages from room.
     *
     */

    public function clear():void{
        _totalMessages = _unreadMessages = 0;
        _messages.removeAll();
    }


    /**
     * Get all room's messages
     * @return
     */

    public function all():ArrayCollection{
        return _messages;
    }


    public function get totalMessages():int {
        return _totalMessages;
    }

    [Bindable]

    public function get unreadMessages():int {
        return  _unreadMessages;
    }


    /**
     *  Either user's fullName (if it's a private chat or system names for public/admins chat
     */

    public function get roomName():String {
        return _roomName;
    }


    /**
     *  Either user's sid (if it's a private chat) or system id for 'ALL'/'ADMINS'
     */


    public function get roomId():Number {
        return _roomId;
    }

    public function get active():Boolean {
        return _active;
    }

    public function set active(value:Boolean):void {
        _active = value;
    }

    public function get visible():Boolean {
        return _visible;
    }

    public function set visible(value:Boolean):void {
        _visible = value;
        if(value) _unreadMessages = 0;
    }

    public function get messages():ArrayCollection {
        return _messages;
    }

    public function get system():Boolean {
        return _system;
    }
}
}