/**
 * User: palkan
 * Date: 8/9/13
 * Time: 2:24 PM
 */
package ru.teachbase.utils.data {
import org.flexunit.asserts.assertEquals;

public class LimitArrayTest {
    public function LimitArrayTest() {
    }

    [Test(description='add elements fewer than limit')]
    public function testAdd():void {

        var arr:LimitArray = new LimitArray(2);

        arr.add('one');
        arr.add('two');

        assertEquals(2,arr.length);

    }

    [Test('exceeds limit test')]
    public function testAddLimit():void {

        var arr:LimitArray = new LimitArray(2);

        arr.add('one');
        arr.add('two');
        arr.add('three');

        assertEquals(2,arr.length);

    }


    [Test('decrease limit test')]
    public function testDecreaseLimit():void {

        var arr:LimitArray = new LimitArray(4);

        arr.add('one');
        arr.add('two');
        arr.add('three');

        arr.limit = 2;

        assertEquals(2,arr.length);
        assertEquals('two',arr.shift());

    }
}
}
