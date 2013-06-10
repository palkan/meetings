/**
 * User: palkan
 * Date: 5/29/13
 * Time: 10:19 AM
 */
package ru.teachbase.utils.extensions {
import org.flexunit.asserts.assertEquals;
import org.flexunit.asserts.assertFalse;
import org.flexunit.asserts.assertTrue;

public class FuncObjectTest {

    private var _obj:FuncObject;
    private var _sum:int = 0;

    private var sum_fun:Function;
    private var mult_fun:Function;

    public function FuncObjectTest() {
        sum_fun = function(a:int,b:int){ _sum+=(a+b);};
        mult_fun= function(a:int,b:int){ _sum+=(a*b);};
    }


    [Before]
    public function setUp():void{
       _obj = new FuncObject();
       _sum = 0;
    }

    [Test(description="simple listen")]
    public function testListen():void {

        _obj.test1 = sum_fun;

        _obj.test1(1,1);

        assertEquals(2, _sum);

    }

    [Test(description="multiple listen")]
    public function testMultipleListen():void {

        _obj.test1 = sum_fun;
        _obj.test1 = mult_fun;

        _obj.test1(2,3);
        assertEquals(6+5, _sum);

    }

    [Test(description="unlisten")]
    public function testUnListen():void {

        _obj.test1 = sum_fun;
        _obj.test1 = mult_fun;
        _obj.deleteFromProperty('test1',sum_fun);
        _obj.deleteFromProperty('test2',sum_fun);

        _obj['test1'].call(null,2,3);
        assertEquals(6, _sum);

    }


    [Test(description="missing listeners")]
    public function testMissingListen():void {
        _obj['test1'] = sum_fun;
        _obj.deleteFromProperty('test1',sum_fun);

        _obj.test1(2,3);

        assertEquals(0,_sum);
    }


    [Test(description="missing listeners error", expects="TypeError")]
    public function testMissingListenError():void {
        _obj['test1'] = sum_fun;
        _obj.deleteFromProperty('test1',sum_fun);

        _obj['test1'](2,3);

    }

}
}
