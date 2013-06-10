package ru.teachbase.utils.logger {
import flash.errors.IllegalOperationError;
import flash.events.EventDispatcher;
import flash.external.ExternalInterface;

import mx.utils.ObjectUtil;

/**
 * Sent if MODE == EVENT
 *
 * @eventType ru.teachbase.utils.logger.LoggerEvent.LOG
 */

[Event(type="ru.teachbase.utils.logger.LoggerEvent",name="tb:log")]

/**
 * Utility class for logging debug messages. It supports the following logging systems:
 * <li>The Console.log function built into JS.</li>
 * <li>The tracing system built into the debugging players.</li>
 * <li>Event-driven (dispatch LogEvent).
 *
 *
 * @author Teachbase
 **/

public class Logger extends EventDispatcher {

    public static var MODE:String = LoggerMode.TRACE;

    public static var LEVEL:uint = LoggerLevel.ERROR;

    public static const instance:Logger = new Logger();


    public function Logger() {
        if (instance) throw new IllegalOperationError("I am singleton!");
    }


    /**
     * Log a message to the output system.
     *
     * @param level    @see LoggerLevel
     * @param args        Message args
     **/
    public static function log(level:uint, ...args):void {
        if (~(level & LEVEL) || MODE === LoggerMode.NONE) return;

        if (MODE === LoggerMode.TRACE) trace.call(null, LoggerLevel.toString(level), ": ", args);
        else {

            var message:String = ((args.length === 1) && ObjectUtil.isSimple(args[0])) ? args[0].toString() : ObjectUtil.toString(args);

            switch (MODE) {
                case LoggerMode.CONSOLE:
                    if (ExternalInterface.available) {
                        ExternalInterface.call('console.log', LoggerLevel.toString(level) + ": " + message);
                    }
                    break;
                case LoggerMode.EVENT:
                    if (instance.hasEventListener(LoggerEvent.LOG)) instance.dispatchEvent(new LoggerEvent(LoggerLevel.toString(level), message));
                default:
                    break;
            }

        }
    }

}
}