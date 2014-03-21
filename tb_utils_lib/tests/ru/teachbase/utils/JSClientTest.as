/**
 * User: palkan
 * Date: 3/20/14
 * Time: 1:55 PM
 */
package ru.teachbase.utils {
import org.flexunit.asserts.assertEquals;

public class JSClientTest {

    private var _target:JSClient;

    [Before]
    public function setUp(){
        _target = new JSClient('window');
    }

    [After]
    public function cleanUp():void {
        _target = null;
    }

    [Test(description="simple values")]
    public function testTojs():void {
        assertEquals('123', _target._tojs(123));
        assertEquals('true', _target._tojs(true));
        assertEquals('false', _target._tojs(false));
        assertEquals('\'123\'', _target._tojs('123'));
        assertEquals('undefined', _target._tojs(null));
        assertEquals('undefined', _target._tojs(undefined));
    }

    [Test(description="objects and arrays")]
    public function testTojs2():void {
        assertEquals('[1,2,3]', _target._tojs([1,2,3]));
        assertEquals('[\'a\',\'b\',\'c\']', _target._tojs(['a','b','c']));
        assertEquals('{field1:1}', _target._tojs({field1:1}));
    }

    [Test(description="nested objects and arrays")]
    public function testTojs3():void {
        assertEquals('[1,{name:\'A\'},\'cat\']', _target._tojs([1,{name:'A'},'cat']));
        assertEquals('{phones:[{num:123},\'+749500110101\']}', _target._tojs({phones:[{num:123},'+749500110101']}));
    }
}
}
