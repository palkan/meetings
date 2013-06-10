/**
 * User: palkan
 * Date: 5/29/13
 * Time: 10:59 AM
 */
package ru.teachbase.utils {
import org.flexunit.asserts.assertEquals;
import org.flexunit.asserts.assertStrictlyEquals;

[RunWith("org.flexunit.runners.Parameterized")]

public class StringsTest {
    public function StringsTest() {
    }

    [Test]
    public function testStrip():void {

        assertEquals('test', Strings.strip('<p>t</p>\n' +
                '<b>e</b>st<br/>'));

    }

    public static function serializeData():Array{

        return [["true", true], ["false",false], ["0.2", 0.2], ["123213",123213], ["str","str"], ['very long text... really long text... yes!','very long text... really long text... yes!']];
    }

    [Test(dataProvider="serializeData")]
    public function testSerialize(input:String, output:*):void {

        assertStrictlyEquals(output, Strings.serialize(input));
    }

    [Test]
    public function testInterpolate():void {
        assertEquals('Hello, Vasya! Today is Monday', Strings.interpolate('Hello, ${1}! Today is ${2}',['Vasya','Monday']));
    }

    public static function domainsData():Array{

        return [
            ["http://ex.re/", "ex.re"], ["https://ex.re","ex.re"], ["ex.re", "ex.re"],
            ["ex.re/","ex.re"], ["sub.doma.in","sub.doma.in"], ['ftp://so.me/',"so.me"],
            ["htp:/ru.ru",null],["exampl.e",null],["http://this.is/your/long/link",null]
        ];
    }

    [Test(dataProvider="domainsData")]
    public function testValidateDomain(domain:String, test:*):void{
        assertEquals(test,Strings.validateDomain(domain));
    }

    [Test]
    public function testTrim():void {
      assertEquals('Hello world!',Strings.trim('  Hello world! '));
    }


    [Test]
    public function testCleanLink():void {
       assertEquals('alert()',Strings.cleanLink('javascript:alert()'));
    }


    [Test]
    public function testExtension():void {
        assertEquals('img',Strings.extension('qerq.img'));
        assertEquals('',Strings.extension('qerq'));
    }

    public static function secsData():Array{
        return [['00:03:00.1',180.1], ['03:00.1',180.1], ['180.1s',180.1], ['3.2m',192], ['3.2h',60*180+720]];
    }

    [Test(dataProvider="secsData")]
    public function testSeconds(time_s:String,time:Number):void{
        assertEquals(time, Strings.seconds(time_s));
    }


    [Test]
    public function testDigits():void {
       assertEquals('01:00:10',Strings.digits(3610,true));
       assertEquals('60:10',Strings.digits(3610));
    }

}
}
