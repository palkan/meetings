/**
 * User: palkan
 * Date: 5/28/13
 * Time: 11:54 AM
 */
package ru.teachbase.model.constants {
public class ErrorCodes {

    public static const UNKNOWN:uint = 0;

    public static const RTMP:uint = 1 << 3;

    public static const APPLICATION:uint = 1 << 2;

    public static const TIMEOUT:uint = RTMP + (1 << 5);
    public static const LIMIT:uint = APPLICATION + (1 << 6);
    public static const NOT_FOUND:uint = APPLICATION + (1 << 7);
    public static const AUTHORIZATION_FAILED:uint = APPLICATION + (1 << 8);

    public static const MEETING_FINISHED:uint = APPLICATION + (1 << 9);

    public static const CONNECTION_FAILED:uint = RTMP+(1 << 10);

    public static const KICKEDOFF:uint = APPLICATION+(1 << 11);

    public static const CONNECTION_DROPPED:uint = RTMP + (1 << 12);

}
}
