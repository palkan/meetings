/**
 * User: palkan
 * Date: 3/20/14
 * Time: 1:10 PM
 */
package ru.teachbase.utils {
import flash.external.ExternalInterface;
import flash.utils.Proxy;
import flash.utils.flash_proxy;

import mx.utils.ObjectUtil;

use namespace flash_proxy;


/**
 * Wrapper for ExternalInterface.call
 *
 * Call JS functions on specific object (which can be any valid js string: 'window', 'var_obj.prop', 'get_obj()', '$('#id')');
 *
 * Uses Proxy magic
 *
 */

public class JSClient extends Proxy{
    private var _target:String;

    public function JSClient(target:String) {
        _target = target;
    }


    internal function _wrap(body:String):String{
        return '(function(){ return '+body+';})';
    }


    internal function _tojs(value:*):String{

        if(value == undefined) return 'undefined';

        if (value is Array){
            return "["+
                    value.map(function(arg:*){
                        return _tojs(arg);
                    }).join(",")
            +"]";
        }else if(ObjectUtil.isSimple(value))
                return value is String ? '\''+value+'\'' : ''+value;
        else{
            var keys = [];

            for(var key in value){
                if(value.hasOwnProperty(key)){
                    keys.push(key+":"+_tojs(value[key]));
                }
            }

            return "{"+keys.join(",")+"}";
        }

    }


    override flash_proxy function callProperty(name:*, ...parameters):*
    {
        if(!ExternalInterface.available) return;

        return ExternalInterface.call(
                _wrap(
                        _target+"."+name+".apply("+_target+","+_tojs(parameters)+")"
                )
        );
    }

    override flash_proxy function deleteProperty(name:*):Boolean
    {
        return true;
    }


    override flash_proxy function setProperty(name:*, value:*):void
    {
        if(!ExternalInterface.available) return;

        ExternalInterface.call(
                _wrap(
                        _target+"."+name+"="+(value is String ? '\''+value+'\'' : value)
                )
        );
    }



    override flash_proxy function getProperty(name:*):*
    {
        if(!ExternalInterface.available) return;

        return ExternalInterface.call(
                _wrap(
                        _target+"."+name
                )
        );

    }

    override flash_proxy function hasProperty(name:*):Boolean
    {
        if(!ExternalInterface.available) return false;

        return ExternalInterface.call(
                _wrap(
                        _target+".hasOwnProperty('"+name+"')"
                )
        );
    }




}
}
