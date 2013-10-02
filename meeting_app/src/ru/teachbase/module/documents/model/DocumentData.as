package ru.teachbase.module.documents.model {
import ru.teachbase.utils.system.registerClazzAlias;

registerClazzAlias(DocumentData);

public dynamic class DocumentData {


    public var id:Number;

    public var file:FileItem;

    public var instance_id:int=0;

    public function DocumentData(object:Object = null) {

        if (object) fromObject(object);

    }


    public function fromObject(obj:Object):void {

        for (var key:String in obj) {

            this[key] = obj[key];

        }

    }

}
}