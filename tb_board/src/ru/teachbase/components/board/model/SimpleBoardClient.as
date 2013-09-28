/**
 * User: palkan
 * Date: 8/20/13
 * Time: 11:11 AM
 */
package ru.teachbase.components.board.model {
import ru.teachbase.components.board.FigureManager;

public class SimpleBoardClient implements IExternalBoardManager {

    public var onConnect:Function;
    public var onData:Function;


    public function SimpleBoardClient(connect:Function, data:Function) {
        onConnect = connect;
        onData = data;
    }


    public function connect(mgr:FigureManager):void{
        onConnect && onConnect(mgr);
    }

    public function send(data:Array):void{

        onData && onData(data);

    }

}
}
