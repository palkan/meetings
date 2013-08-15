/**
 * User: palkan
 * Date: 8/13/13
 * Time: 1:56 PM
 */
package ru.teachbase.utils.helpers {
import flash.utils.ByteArray;

public function dummyBytes(length:int):ByteArray {

        var ba:ByteArray = new ByteArray();

        while (length > 0) {
            ba.writeByte(0);
            length--;
        }

        return ba;

    }
}
