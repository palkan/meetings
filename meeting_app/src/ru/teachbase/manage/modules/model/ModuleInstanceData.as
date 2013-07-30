/**
 * User: palkan
 * Date: 6/3/13
 * Time: 6:09 PM
 */
package ru.teachbase.manage.modules.model{
import ru.teachbase.utils.system.registerClazzAlias;

/**
 *  ModuleId - InstanceId - PanelId linkage data from server
 */

registerClazzAlias(ModuleInstanceData);

public class ModuleInstanceData {

    /**
     *  Module id
     */

    public var moduleId:String;

    /**
     * Module instance id
     *
     */

    public var instanceId:uint;

    /**
     * Module panel id (if equals to 0 then instance is not on stage)
     */

    public var panelId:uint;

    /**
     *
     * @param module
     * @param instance
     */

    public function ModuleInstanceData(module:String = "", instance:uint = 0, panel:uint = 0) {
        moduleId = module;
        instanceId = instance;
        panelId = panel;
    }
}
}
