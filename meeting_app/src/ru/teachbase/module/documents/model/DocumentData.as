package ru.teachbase.module.documents.model {
import ru.teachbase.utils.system.registerClazzAlias;

registerClazzAlias(DocumentData);

public dynamic class DocumentData {


    /**
     * Type of document.
     * Can be:
     * <li> <i>wb</i></li>
     * <li> <i>image</i></li>
     * <li> <i>video</i></li>
     * <li> <i>audio</i></li>
     * <li> <i>document</i></li>
     * <li> <i>presentation</i></li>
     */

    public var type:String;

    public var id:Number;

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