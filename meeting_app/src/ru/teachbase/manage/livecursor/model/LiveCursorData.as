/**
 * User: palkan
 * Date: 2/19/14
 * Time: 2:34 PM
 */
package ru.teachbase.manage.livecursor.model {
import ru.teachbase.utils.extensions.FromObject;
import ru.teachbase.utils.system.registerClazzAlias;


registerClazzAlias(LiveCursorData);

public class LiveCursorData extends FromObject {

    /**
     * User id
     */
    public var uid:Number;
    /**
     * Target id (= instance id)
     */
    public var tid:int;
    public var x:Number;
    public var y:Number;
    /**
     * Initial target width
     */
    public var iw:Number;
    public var color:uint;

    /**
     * Fix this cursor or not
     */

    public var anchor:Boolean = false;

    public function LiveCursorData(data:Object=null) {
        super(data);
    }
}
}
