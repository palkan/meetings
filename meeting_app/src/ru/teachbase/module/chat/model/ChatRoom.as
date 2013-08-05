package ru.teachbase.module.chat.model {
import flashx.textLayout.elements.DivElement;
import flashx.textLayout.elements.FlowElement;
import flashx.textLayout.elements.LinkElement;
import flashx.textLayout.elements.ParagraphElement;
import flashx.textLayout.elements.SpanElement;
import flashx.textLayout.elements.TextFlow;

import mx.collections.ArrayCollection;

import ru.teachbase.utils.Strings;

public class ChatRoom {

    private var _messages:ArrayCollection;
    private var _roomId:Number;
    private var _roomName:String;
    private var _unreadMessages:int = 0;
    private var _totalMessages:int = 0;
    private var _active:Boolean = true;
    private var _visible:Boolean = false;

    private var _system:Boolean;

    private var _textFlow:TextFlow;


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

        _textFlow = new TextFlow();
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


        const timer:Date = new Date(Math.floor(message.timestampS));

        var par:ParagraphElement = new ParagraphElement();
        par.fontSize = 13;
        par.color = "0x515151";
        par.paragraphEndIndent = 2;

        var span:SpanElement = new SpanElement();
        span.color = message.color;
        span.text = message.name+' (' + Strings.zero(timer.hours) + ':' + Strings.zero(timer.minutes) + '): ';

        par.addChild(span);

        var elements:Array = bodyToElements(message.body,[]);

        for each(var el:FlowElement in elements) par.addChild(el);

        // HACK: RichEditableText create empty Paragraph if TextFlow has no children; but we don't need this fucking paragraph - remove!

        if(_totalMessages === 1 && _textFlow.numChildren === 1) _textFlow.removeChildAt(0);

        _textFlow.addChild(par);



    }


    private function bodyToElements(body:String, elements:Array):Array{

       if(!body) return elements;

       var matches:Array =  body.match(/^(.+)?(http(?:s)?:\/\/[_\d\w\.\-]+\.\w{2,3}[^\s]+)(.+)?/);

       if(matches){

           if(matches[1]){
               var span:SpanElement = new SpanElement();
               span.text = matches[1];
               elements.push(span);
           }

           var link:LinkElement = new LinkElement();
           link.href = matches[2];
           link.target = "_blank";

           var linkSpan:SpanElement = new SpanElement();
           linkSpan.text = matches[2];

           link.addChild(linkSpan);

           elements.push(link);

           return bodyToElements(matches[3],elements);
       }

        var textSpan:SpanElement = new SpanElement();
        textSpan.text = body;
        elements.push(textSpan);

        return elements;
    }

    /**
     *
     * Remove all messages from room.
     *
     */

    public function clear():void{
        _totalMessages = _unreadMessages = 0;
        _messages.removeAll();
        _textFlow.replaceChildren(0,_textFlow.numChildren);
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

    public function set roomName(value:String):void {
        _roomName = value;
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

    public function get textFlow():TextFlow {
        return _textFlow;
    }


}
}