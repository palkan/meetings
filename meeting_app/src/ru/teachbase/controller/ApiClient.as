/**
 * User: palkan
 * Date: 12/12/13
 * Time: 5:55 PM
 */
package ru.teachbase.controller {
import flash.external.ExternalInterface;

import ru.teachbase.model.App;
import ru.teachbase.utils.shortcuts.debug;

public class ApiClient {

    public function ApiClient(){
        if(ExternalInterface.available){
            ExternalInterface.addCallback('send',send);
        }
    }

    /**
     *
     * @param path
     * @param args
     */

    public function send(path:String,...args):void{

        debug('[api]',path,args);

        try{
            var path_list:Array = path.split('.');

            var obj:* = App[path_list[0]];

            for(var i:int = 1, size:int = path_list.length-1; i < size; i++){
                if(obj.hasOwnProperty(path_list[i])) obj = obj[path_list[i]];
                else return;
            }

            var method:String = path_list[size-1];

            if(method.indexOf("=")>0){
                method = (path_list[size-1] as String).substring(0,-1);
                obj[method] = args[0];
            }else{
                obj[method].apply(null,args);
            }
        }catch(e){
            debug('[api] error',e);
        }

    }

}
}
