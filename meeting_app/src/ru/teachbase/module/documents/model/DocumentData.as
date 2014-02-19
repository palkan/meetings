package ru.teachbase.module.documents.model {
import ru.teachbase.utils.extensions.FromObject;
import ru.teachbase.utils.system.registerClazzAlias;

registerClazzAlias(DocumentData);

public dynamic class DocumentData extends FromObject{


    public var id:Number;

    public var file:FileItem;

    public var instance_id:int=0;

    public function DocumentData(object:Object = null) {
        super(object);
    }


}
}