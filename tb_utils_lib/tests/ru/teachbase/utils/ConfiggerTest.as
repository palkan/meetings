/**
 * User: palkan
 * Date: 5/29/13
 * Time: 2:34 PM
 */
package ru.teachbase.utils {
import flash.events.Event;

import org.flexunit.asserts.assertEquals;
import org.flexunit.asserts.fail;
import org.flexunit.async.Async;
import org.hamcrest.assertThat;
import org.hamcrest.object.hasProperties;

import ru.teachbase.utils.shortcuts.config;

public class ConfiggerTest {
    public function ConfiggerTest() {
    }


    [Before]
    public function setUp(){

    }

    [After]
    public function tearDown(){
        Configger.setDefaults({});
    }

    [Test]
    public function testSimpleSaveLoad():void {
        config('test/id',1);
        assertEquals(1,config('test/id'));
    }

    [Test]
    public function testManySaveLoad():void {
        config('test/id',1);
        config('test/name','test');
        assertThat(config('test'),hasProperties({id:1,name:'test'}));
    }

    [Test(async)]
    public function testExternalJson():void{
        config("external","../../../assets/config.json");
        Async.handleEvent(this,Configger.instance,Event.COMPLETE,verifyLoad,5000,null,function(){fail('Event timeout');});
        Configger.loadConfig();
    }

    protected function verifyLoad(...args):void{
        assertEquals("ru",config("lang"));
    }

}
}
