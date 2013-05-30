/**
 * User: palkan
 * Date: 5/29/13
 * Time: 12:34 PM
 */
package ru.teachbase.model {
import ru.teachbase.utils.Configger;
import ru.teachbase.utils.shortcuts.config;

[Bindable]
public class CurrentUser extends User {

    public var sharing:SharingModel = new SharingModel();
    public var settings:UserLocalSettings;

    public function CurrentUser() {
        super();
        settings = new UserLocalSettings(config(Configger.COOKIE_NS));
    }

}
}
