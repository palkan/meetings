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

    function createPanel(id:uint = 0):IModulePanel;

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
