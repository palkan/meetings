/**
 * User: palkan
 * Date: 5/24/13
 * Time: 7:51 PM
 */
package ru.teachbase.utils.shortcuts {
import ru.teachbase.utils.logger.Logger;
import ru.teachbase.utils.logger.LoggerLevel;

/**
 *
 * Log WARNING message.
 *
 */

public function warning(...args):void {
    Logger.log.apply(null,[LoggerLevel.WARNING].concat(args));
}
}
