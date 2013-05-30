/**
 * User: palkan
 * Date: 5/29/13
 * Time: 3:21 PM
 */
package ru.teachbase.model {
import org.flexunit.assertThat;
import org.hamcrest.object.hasProperties;

import ru.teachbase.utils.Configger;
import ru.teachbase.utils.shortcuts.config;

public class CurrentUserTest {
    public function CurrentUserTest() {
    }


    [Test]
    public function testInitSettings(){
        config(Configger.COOKIE_NS+'/camID','myCam');
        config(Configger.COOKIE_NS+'/micID',0);

        var user:CurrentUser = new CurrentUser();

        assertThat(user.settings,hasProperties({volume: 80, micID: 0, camID: 'myCam'}));
    }
}
}
