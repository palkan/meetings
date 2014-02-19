/**
 * User: palkan
 * Date: 5/28/13
 * Time: 11:54 AM
 */
package ru.teachbase.constants {
public class ErrorCodes {

    public static const UNKNOWN:uint = 0;

    public static const RTMP:uint = 1 << 3;

    public static const APPLICATION:uint = 1 << 2;

    public static const RECORDING:uint = 1 << 4;

    public static const TIMEOUT:uint = RTMP + (1 << 5);
    public static const LIMIT:uint = APPLICATION + (1 << 6);
    public static const NOT_FOUND:uint = APPLICATION + (1 << 7);
    public static const AUTHORIZATION_FAILED:uint = APPLICATION + (1 << 8);

    public static const MEETING_FINISHED:uint = APPLICATION + (1 << 9);

    public static const CONNECTION_FAILED:uint = RTMP+(1 << 10);

    public static const KICKEDOFF:uint = APPLICATION+(1 << 11);

    public static const CONNECTION_DROPPED:uint = RTMP + (1 << 12);

    public static const FILE_LOAD_ERROR:uint = RECORDING + (1 << 13);
    public static const PACKET_DECODE_FAILED:uint = RECORDING + (1 << 14);
    public static const HLS_STREAM_FAILED:uint = RECORDING + (1 << 15);

    public static const MEETING_FAILED:uint = APPLICATION + (1 << 16);
    public static const PING_TIMEOUT:uint = APPLICATION + (1 << 17);
    public static const HARD_TIMEOUT:uint = APPLICATION + (1 << 18);
}
}
