/**
 * User: palkan
 * Date: 10/29/13
 * Time: 11:02 AM
 */
package ru.teachbase.components.board {
import ru.teachbase.error.SingletonError;

public class BoardModule {

    /**
     * [instID] : BoardContent
     */
    protected const elements:Object = {};

    protected static const instance:BoardModule = new BoardModule();

    public function BoardModule(){
        if(instance) throw new SingletonError();
    }

    public static function getElement(id:int):BoardContent{

        if(instance.elements[id]) return instance.elements[id];

        const board:BoardContent = new BoardContent();

        board.controlbar = new WBControlbar();

        board.ex_manager = new BoardExternalManager(id);

        instance.elements[id] = board;

        return board;
    }

    public static function hasElement(id:int):Boolean{
        return !!instance.elements[id];
    }

    public static function disposeElement(id:int):void{
        if(instance.elements[id]){

            const board:BoardContent = instance.elements[id];

            board.ex_manager.dispose();
            board.manager.dispose();

            delete instance.elements[id];

        }
    }

}
}
