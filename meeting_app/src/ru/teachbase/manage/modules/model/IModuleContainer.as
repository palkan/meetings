/**
 * User: palkan
 * Date: 6/5/13
 * Time: 3:21 PM
 */
package ru.teachbase.manage.modules.model {
public interface IModuleContainer{

    /**
     * Create new IModulePanel and add it to stage (invisible)
     * @return
     */

    function createPanel(data:ModuleInstanceData):IModulePanel;

    /**
     * Remove panel from stage.
     *
     * @param panel
     */

    function destroyPanel(panel:IModulePanel):void;

    /**
     * Lock layout to prevent changes
     */

    function lock():void;

    /**
     * Unlock layout
     */

    function unlock():void;
}
}
