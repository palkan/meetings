/**
 * User: palkan
 * Date: 6/11/13
 * Time: 4:24 PM
 */
package ru.teachbase.utils {


/**
 *
 *
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


    /**
     * Creates new DelayedTask
     *
     * @param delay  Delay time (min time between commits)
     * @param commit Function to commit changes
     */

    public function DelayedWriter(delay:Number = 100, commit:Function = null){
        _delayTime = delay;
        commitFunction = commit;
    }


    public function
}
}
