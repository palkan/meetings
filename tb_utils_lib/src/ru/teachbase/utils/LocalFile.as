/**
 * User: palkan
 * Date: 8/5/13
 * Time: 2:14 PM
 */
package ru.teachbase.utils {
import flash.net.FileReference;

public class LocalFile {

    /**
     *
     * Save data to file locally.
     *
     * @param data
     * @param name
     */

    public static function save(data:*, name:String):void{

        var fileReference:FileReference = new FileReference();
        fileReference.save(data, name);
    }

}
}
