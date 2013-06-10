/**
 * User: palkan
 * Date: 5/24/13
 * Time: 7:44 PM
 */
package ru.teachbase.utils.shortcuts {
import ru.teachbase.utils.logger.Logger;
import ru.teachbase.utils.logger.LoggerLevel;

/**
 * Log DEBUG message
 * @param args
 */

public function debug(...args):void{
     Logger.log.apply(null,[LoggerLevel.DEBUG].concat(args));
}
}
