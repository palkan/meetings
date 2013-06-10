/**
 * User: palkan
 * Date: 5/24/13
 * Time: 7:50 PM
 */
package ru.teachbase.utils.shortcuts {
import ru.teachbase.utils.GlobalError;
import ru.teachbase.utils.logger.Logger;
import ru.teachbase.utils.logger.LoggerLevel;

/**
 * Invoke GlobalErrorEvent
 */

public function error(message:String, code:uint = 0):void {
    Logger.log.call(null,LoggerLevel.ERROR,message,code);

    GlobalError.raise(message,code);
}
}
