/**
 * User: palkan
 * Date: 5/30/13
 * Time: 10:35 AM
 */
package ru.teachbase.constants {
public class NetStreamStatusCodes {

    /**
     *  Publish was successful.
     */
    public static const PUBLISH_START:String = "NetStream.Publish.Start";
    /**
     * The unpublish operation was successfuul.
     */
    public static const UNPUBLISH_SUCCESS:String = "NetStream.Unpublish.Success";
    /**
     *  Unknown error
     */
    public static const FAILED:String = "NetStream.Failed";
    /**
     * Flash Player is not receiving data quickly enough to fill the buffer.
     * Data flow is interrupted until the buffer refills, at which time a NetStream.Buffer.Full message is sent and the stream begins playing again.
     */
    public static const BUFFER_EMPTY:String = "NetStream.Buffer.Empty";

    /**
     * The buffer is full and the stream begins playing.
     */
    public static const BUFFER_FULL:String = "NetStream.Buffer.Full";

    /**
     * Data has finished streaming, and the remaining buffer is emptied. Note: Not supported in AIR 3.0 for iOS.
     */
    public static const BUFFER_FLUSH:String = "NetStream.Buffer.Flush";

    /**
     * An error has occurred in playback for a reason other than those listed elsewhere in this table, such as the subscriber not having read access. Note: Not supported in AIR 3.0 for iOS.
     */

    public static const PLAY_FAILED:String = "NetStream.Play.Failed";

    /**
     * Caused by a play list reset. Note: Not supported in AIR 3.0 for iOS.
     */

    public static const PLAY_RESET:String = "NetStream.Play.Reset";

    /**
     *  Playback has started.
     */
    public static const PLAY_START:String = "NetStream.Play.Start";
    /**
     *  Playback has stopped.
     */
    public static const PLAY_STOP:String = "NetStream.Play.Stop";


    /**
     * The file passed to the NetStream.play() method can't be found.
     */
    public static const NOT_FOUND:String = "NetStream.Play.StreamNotFound";

    /**
     * The seek fails, which happens if the stream is not seekable.
     */
    public static const SEEK_FAILED:String = "NetStream.Seek.Failed";
    /**
     *  The seek operation is complete.
     */
    public static const SEEK_NOTIFY:String = "NetStream.Seek.Notify";
    /**
     * For video downloaded progressively, the user has tried to seek or play past the end of the video data that has downloaded thus far, or past the end of the video once the entire file has downloaded.
     * The info.details property of the event object contains a time code that indicates the last valid position to which the user can seek.
     */
    public static const SEEK_INVALID:String = "NetStream.Seek.InvalidTime";
    /**
     * The step operation is complete. Note: Not supported in AIR 3.0 for iOS.
     */
    public static const STEP_NOTIFY:String = "NetStream.Step.Notify";
    /**
     * The stream is paused.
     */
    public static const PAUSE_NOTIFY:String = "NetStream.Pause.Notify";
    /**
     * The stream is resumed.
     */
    public static const UNPAUSE_NOTIFY:String = "NetStream.Unpause.Notify";
}
}
