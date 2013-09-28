/**
 * User: palkan
 * Date: 8/19/13
 * Time: 3:06 PM
 */
package ru.teachbase.components.board.model {
import ru.teachbase.components.board.FigureManager;

public interface IExternalBoardManager{

    /**
     * Connect figure manager and external manager together.
     * @param mgr
     */

    function connect(mgr:FigureManager):void;

    /**
     *
     * Send changes data to external manager.
     *
     * @param data
     */

    function send(data:Array):void;

}
}
