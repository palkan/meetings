/**
 * User: palkan
 * Date: 2/19/14
 * Time: 2:40 PM
 */
package ru.teachbase.utils.extensions {
public class FromObject {

    public function FromObject(data:Object = null) {
        data && fromObject(data);
    }

    public function fromObject(obj:Object):void{
        for(var key:String in obj){
            this[key] = obj[key];
        }
    }
}
}
