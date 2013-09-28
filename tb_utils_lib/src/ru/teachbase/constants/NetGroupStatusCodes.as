/**
 * User: palkan
 * Date: 5/30/13
 * Time: 10:35 AM
 */
package ru.teachbase.constants {
public class NetGroupStatusCodes {

    /**
     *  The NetGroup is successfully constructed and authorized to function. The <code>info.group</code> property indicates which NetGroup has succeeded.
     */
    public static const CONNECTED:String = "NetGroup.Connect.Success";
    /**
     * The NetGroup is not authorized to function. The <code>info.group</code> property indicates which NetGroup was denied.
     */
    public static const REJECTED:String = "NetGroup.Connect.Rejected";
    /**
     *  The NetGroup connection attempt failed. The <code>info.group</code> property indicates which NetGroup failed.
     */
    public static const FAILED:String = "NetGroup.Connect.Failed";
    /**
     * Sent when a new Group Posting is received. The <code>info.message:Object</code> property is the message. The <code>info.messageID:String</code> property is this message's messageID.
     */
    public static const POST_MESSAGE:String = "NetGroup.Posting.Notify";

    /**
     * Sent when a message directed to this node is received. The <code>info.message:Object</code> property is the message.
     * The <code>info.from:String</code> property is the groupAddress from which the message was received.
     * The <code>info.fromLocal:Boolean</code> property is TRUE if the message was sent by this node (meaning the local node is the nearest to the destination group address), and FALSE if the message was received from a different node. To implement recursive routing, the message must be resent with NetGroup.sendToNearest() if <code>info.fromLocal</code> is FALSE.
     */
    public static const MESSAGE_SENT_TO:String = "NetGroup.SendTo.Notify";

    /**
     * Sent when a neighbor connects to this node. The <code>info.neighbor:String</code> property is the group address of the neighbor. The <code>info.peerID:String</code> property is the peer ID of the neighbor.
     */
    public static const NEIGHBOR_CONNECT:String = "NetGroup.Neighbor.Connect";

    /**
     * Sent when a neighbor disconnects from this node. The <code>info.neighbor:String</code> property is the group address of the neighbor. The <code>info.peerID:String</code> property is the peer ID of the neighbor.
     */

    public static const NEIGHBOR_DISCONNECT:String = "NetGroup.Neighbor.Disconnect";

    /**
     * Sent when a fetch request for an object (previously announced with NetGroup.Replication.Fetch.SendNotify) fails or is denied. A new attempt for the object will be made if it is still wanted. The <code>info.index:Number</code> property is the index of the object that had been requested.
     */

    public static const REPLICATION_FAILED:String = "NetGroup.Replication.Fetch.Failed";

    /**
     *  Sent when a fetch request was satisfied by a neighbor. The <code>info.index:Number</code> property is the object index of this result. The <code>info.object:Object</code> property is the value of this object. This index will automatically be removed from the Want set. If the object is invalid, this index can be re-added to the Want set with NetGroup.addWantObjects().
     */
    public static const REPLICATION_DATA:String = "NetGroup.Replication.Fetch.Result";
    /**
     *  Sent when a neighbor has requested an object that this node has announced with NetGroup.addHaveObjects(). This request must eventually be answered with either NetGroup.writeRequestedObject() or NetGroup.denyRequestedObject(). Note that the answer may be asynchronous. The <code>info.index:Number</code> property is the index of the object that has been requested. The <code>info.requestID:int</code> property is the ID of this request, to be used by NetGroup.writeRequestedObject() or NetGroup.denyRequestedObject().
     */
    public static const REPLICATION_REQUEST:String = "NetGroup.Replication.Request";


    /**
     * Sent when the Object Replication system is about to send a request for an object to a neighbor.The <code>info.index:Number</code> property is the index of the object that is being requested.
     */
    public static const REPLICATION_SEND:String = "NetGroup.Replication.Fetch.SendNotify";

}
}
