package ru.teachbase.utils {

import flash.errors.IllegalOperationError;
import flash.events.ErrorEvent;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.IOErrorEvent;
import flash.events.SecurityErrorEvent;
import flash.net.SharedObject;
import flash.net.URLLoader;
import flash.net.URLRequest;

import mx.core.FlexGlobals;
import mx.utils.ObjectUtil;

import ru.teachbase.utils.shortcuts.debug;
import ru.teachbase.utils.shortcuts.warning;


/**
 * Sent when the configuration has been successfully retrieved
 *
 * @eventType flash.events.Event.COMPLETE
 */
[Event(name="complete", type="flash.events.Event")]

public final class Configger extends EventDispatcher {

    public static const COOKIE_NS:String = 'tb:local';

    public static const instance:Configger = new Configger();


    private var _config:Object = {};

    public function Configger() {

        if (instance)
            throw new IllegalOperationError(this + ' is a Singleton. Use static methods and properties.');
    }


    /**
     *
     *  Load configuration.
     *
     *  1. From cookies.
     *  2. From flashvars.
     *  3. From external file.
     *
     *
     */

    public static function loadConfig():void {
        instance.loadCookies();
        instance.loadFlashvars();
        if (config.external)
            instance.loadExternal();
        else
            instance.dispatchEvent(new Event(Event.COMPLETE));
    }


    /**
     *
     * Set default configuration values.
     *
     * Use <b>before</b> <i>loadConfig()</i>, 'cause this method overrides everything was set before.
     *
     * @param obj
     */

    public static function setDefaults(obj:Object):void {

        instance._config = obj;

    }

    /**
     *
     * @param param
     * @param value
     * @return
     */

    public static function saveCookie(param:String, value:*):Boolean {
        try {
            var cookie:SharedObject = SharedObject.getLocal('ru.teachbase', '/');
            cookie.data[param] = value;
            cookie.flush();
            instance.setConfigParam(COOKIE_NS+'/'+param, value);
            return true;
        } catch (e:Error) {
            warning("Saving cookies error", e.message);
        }

        return false;
    }

    private function loadCookies():void {
        try {
            var cookie:SharedObject = SharedObject.getLocal('ru.teachbase', '/');
            writeCookieData(cookie.data);
        } catch (e:Error) {
            warning("Loading cookies error", e.message);
        }
    }

    /** Overwrite cookie data. **/
    private function writeCookieData(obj:Object):void {
        for (var cfv:String in obj) {
            setConfigParam(COOKIE_NS+'/'+cfv.toLowerCase(), obj[cfv]);
        }
    }

    private function loadFlashvars():void {
        try {
            for (var key:String in FlexGlobals.topLevelApplication.parameters)
                _config[key] = FlexGlobals.topLevelApplication.parameters[key];
        } catch (e:Error) {
            warning("Loading flashvars error", e.message);
        }
    }

    private function loadExternal():void {
        var jsonLoader:URLLoader = new URLLoader();
        jsonLoader.addEventListener(IOErrorEvent.IO_ERROR, loadFail);
        jsonLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, loadFail);
        jsonLoader.addEventListener(Event.COMPLETE, loadComplete);
        jsonLoader.load(new URLRequest(_config.external));
    }

    private function loadComplete(e:Event):void {
        debug("External config loaded");

        var loaded_json:String = String((e.target as URLLoader).data);

        var parsedObj:Object = JSON.parse(loaded_json);

        jsonToConfig(parsedObj);
        dispatchEvent(new Event(Event.COMPLETE));

    }


    private function jsonToConfig(obj:Object):void {

        for (var key:String in obj) {
            setConfigParam(key, obj[key]);
        }

    }


    private function loadFail(e:ErrorEvent):void {
        warning("External config failed: url " + _config.external, "Error: " + e.text);
        dispatchEvent(new Event(Event.COMPLETE));
    }


    private static function setObjectParam(obj:Object, property:String, value:*):void{
        var i:int;
        if((i = property.indexOf('/'))>-1){
            var name:String = property.substr(0,i);
            (!obj.hasOwnProperty(name)) && (obj[name] = {});
            setObjectParam(obj[name],property.substr(i+1),value);
        }else
            obj[property] = value;
    }


    private static function getObjectParam(obj:Object, property:String):*{
        var i:int;
        if((i = property.indexOf('/'))>-1){
            var name:String = property.substr(0,i);
            if(!obj.hasOwnProperty(name)) return null;
            return getObjectParam(obj[name],property.substr(i+1));
        }else
            return obj[property];
    }


    /**
     *
     * @param name  property name as a path
     * @param value
     */


    public function setConfigParam(name:String, value:*):void {
        setObjectParam(_config,name,Strings.serialize(Strings.trim(value)));
    }

    /**
     * Return config param <code>name</code> if it exists, otherwise return <code>null</code>
     * @param name
     *
     */
    public function value(name:String):* {
       return getObjectParam(_config,name);
    }


    public function get config():Object {
        return _config;
    }


    public static function get config():Object {
        return Configger.instance.config;
    }

}
}
