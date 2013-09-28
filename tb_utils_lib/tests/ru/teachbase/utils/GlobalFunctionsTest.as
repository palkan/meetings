/**
 * User: palkan
 * Date: 5/29/13
 * Time: 10:59 AM
 */
package ru.teachbase.utils {
import flash.utils.ByteArray;

import org.flexunit.assertThat;
import org.flexunit.asserts.assertTrue;
import org.hamcrest.object.hasProperties;

import ru.teachbase.utils.system.registerClazzAlias;

public class GlobalFunctionsTest {
    public function GlobalFunctionsTest() {
    }

    private function reserialize(obj:*):* {
        var ba:ByteArray = new ByteArray();
        ba.writeObject(obj);
        ba.position = 0;
        var res:* = ba.readObject();
        return res;
    }

    [Test]
    public function testRegisterClazzAlias():void {

        registerClazzAlias(Test);

        var t1:Test = new Test('test', 1);
        var t2 = reserialize(t1);

        assertTrue(t2 is Test);
        assertThat(t2,hasProperties({p1:'test',p2:1}));
    }

}
}


internal class Test {

    protected var _p1:String;
    protected var _p2:int;

    function Test(p1:String = "", p2:int = 0):void {
        _p1 = p1;
        _p2 = p2;
    }

    public function get p1():String {
        return _p1;
    }

    public function get p2():int {
        return _p2;
    }

    public function set p1(value:String):void {
        _p1 = value;
    }

    public function set p2(value:int):void {
        _p2 = value;
    }

}
