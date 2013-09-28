package ru.teachbase.module.documents.model {
import ru.teachbase.utils.system.registerClazzAlias;

registerClazzAlias(WorkplaceData);

public dynamic class WorkplaceData {


    /**
     * Type of change.
     * Can be:
     * <li> <i>idle</i> - no document loaded </li>
     * <li> <i>progress</i> - someone's loading document</li>
     * <li> <i>active</i> - document's loaded</li>
     */

    public var type:String;

    public function WorkplaceData(object:Object = null) {

        if (object) fromObject(object);

    }


    public function fromObject(obj:Object):void {

        for (var key:String in obj) {

            this[key] = obj[key];

        }

    }

}
}