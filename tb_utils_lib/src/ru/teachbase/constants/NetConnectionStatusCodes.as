/**
 * User: palkan
 * Date: 5/28/13
 * Time: 4:30 PM
 */
package ru.teachbase.constants {
public class NetConnectionStatusCodes {
    /**
     *  The NetConnection.call() method was not able to invoke the server-side method or command.
     */
    public static const CALL_FAILED:String = "NetConnection.Call.Failed";
    /**
     *  The connection was closed successfully.
     */
    public static const CLOSED:String = "NetConnection.Connect.Closed";
    /**
     * The connection attempt failed.
     */
    public static const FAILED:String = "NetConnection.Connect.Failed";
    /**
     *  The connection attempt did not have permission to access the application.
     */
    public static const REJECTED:String = "NetConnection.Connect.Rejected";
    /**
     *  The connection attempt succeeded.
     */
    public static const SUCCESS:String = "NetConnection.Connect.Success";
}
}
