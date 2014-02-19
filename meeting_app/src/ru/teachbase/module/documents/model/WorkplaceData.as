package ru.teachbase.module.documents.model {
import ru.teachbase.utils.extensions.FromObject;
import ru.teachbase.utils.system.registerClazzAlias;

registerClazzAlias(WorkplaceData);

public dynamic class WorkplaceData extends FromObject{


    /**
     * Type of change.
     * Can be:
     * <li> <i>idle</i> - no document loaded </li>
     * <li> <i>progress</i> - someone's loading document</li>
     * <li> <i>active</i> - document's loaded</li>
     */

    public var type:String;

    public function WorkplaceData(object:Object = null) {

        super(object);

    }


}
}