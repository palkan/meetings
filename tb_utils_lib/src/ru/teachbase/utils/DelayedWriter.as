/**
 * User: palkan
 * Date: 6/11/13
 * Time: 4:24 PM
 */
package ru.teachbase.utils {
import flash.utils.Timer;
import flash.utils.setTimeout;


/**
 *
 *  DelayedWriter used to call some function with a restriction to "calls per time" value.
 *
 *  It has three different strategies:
 *
 *      <li><b>REWRITE</b> - replace old data with a new one (default)</li>
 *      <li><b>COLLECT</b> - store all data in array and commit as array</li>
 *      <li><b>MERGE</b> - merge old data with a new one (use <code>mergeFunction</code>).
 *      <b>Note:</b> if <code>mergeFunction</code> is not provided backoffs to REWRITE (aka <i>stupid merge</i>) strategy</li>
 *
 */

public class DelayedWriter {

    public static const REWRITE:String = "rewrite";
    public static const COLLECT:String = "collect";
    public static const MERGE:String = "merge";

    private static const WAITING:uint = 1;
    private static const READY:uint = 1 << 1;

    public var mergeFunction:Function;
    public var commitFunction:Function;

    private var _delayTime:Number;

    private var state:uint = READY;

    private var _data:*;

    private var _buffer:*;

    private var _mode:String = REWRITE;

    private var _timeHandler:uint;

    /**
     * Creates new DelayedWriter
     *
     * @param delay  Delay time (min time between commits)
     * @param commit Function to commit changes
     */

    public function DelayedWriter(delay:Number = 100, commit:Function = null){
        _delayTime = delay;
        commitFunction = commit;
    }


    /**
     * Add data to buffer or commit immediately if buffer is empty
     *
     * @param data
     */

    public function write(data:*):void{

        this[_mode](data);

        if(!_timeHandler){

            commitFunction && commitFunction(_buffer);

            clear();

            _timeHandler = setTimeout(timeout,_delayTime);
        }

    }


    private function timeout():void{
        _timeHandler = null;
        _buffer && commitFunction && commitFunction(_buffer);
        _buffer && clear();
    }

    private function clear():void{
        if(_mode == COLLECT) _buffer.length = 0;
        else _buffer = null;
    }


    private function rewrite(data:*):void{
        _buffer = data;
    }

    private function collect(data:*):void{
        _buffer.push(data);
    }


    private function merge(data:*):void{

        if(mergeFunction){
            _buffer = mergeFunction(_buffer,data);
        }else
             rewrite(data);
    }

    /**
     * Set writer's mode (REWRITE, COLLECT or MERGE).
     *
     * <b>Note:</b> updating mode clears buffer.
     *
     * @param value
     */

    public function set mode(value:String):void{

        if(_mode == value) return;

        _mode = value;

        clear();

    }
}
}
