/**
 * User: palkan
 * Date: 5/24/13
 * Time: 7:19 PM
 */
package ru.teachbase.utils.logger {
public class LoggerLevel {

    public static const ERROR:uint = 1;
    public static const WARNING:uint = ERROR + (1 << 1);
    public static const DEBUG:uint = WARNING + (1 << 2);

    public static function toString(level:uint):String{

        switch(level){
            case ERROR: return "ERROR!";
            case WARNING: return "WARNING!";
        }

        return "DEBUG:";
    }
}
}
