/**
 * User: palkan
 * Date: 9/30/13
 * Time: 5:19 PM
 */
package ru.teachbase.manage.file.model {
import ru.teachbase.utils.system.registerClazzAlias;


registerClazzAlias(FileProcessData);

public class FileProcessData {

    public var status:String;
    public var result:Object;

    public function FileProcessData() {
    }
}
}
