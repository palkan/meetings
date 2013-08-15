package ru.teachbase.manage.publish {
import flash.events.ActivityEvent;
import flash.events.AsyncErrorEvent;
import flash.events.ErrorEvent;
import flash.events.IOErrorEvent;
import flash.events.NetStatusEvent;
import flash.media.Camera;
import flash.media.H264Level;
import flash.media.H264Profile;
import flash.media.H264VideoStreamSettings;
import flash.media.Microphone;
import flash.net.NetConnection;
import flash.net.NetStream;

import ru.teachbase.components.notifications.Notification;

import ru.teachbase.constants.NetStreamStatusCodes;
import ru.teachbase.constants.PacketType;
import ru.teachbase.constants.PublishQuality;
import ru.teachbase.events.ChangeEvent;
import ru.teachbase.manage.*;
import ru.teachbase.manage.rtmp.RTMPListener;
import ru.teachbase.manage.rtmp.RTMPManager;
import ru.teachbase.manage.rtmp.events.RTMPEvent;
import ru.teachbase.manage.rtmp.model.Packet;
import ru.teachbase.manage.session.SessionManager;
import ru.teachbase.model.App;
import ru.teachbase.model.SharingModel;
import ru.teachbase.model.User;
import ru.teachbase.net.stats.RTMPWatch;
import ru.teachbase.utils.CameraQuality;
import ru.teachbase.utils.CameraUtils;
import ru.teachbase.utils.MicrophoneUtils;
import ru.teachbase.utils.Permissions;
import ru.teachbase.utils.Strings;
import ru.teachbase.utils.shortcuts.debug;
import ru.teachbase.utils.shortcuts.error;
import ru.teachbase.utils.shortcuts.notify;
import ru.teachbase.utils.shortcuts.translate;
import ru.teachbase.utils.shortcuts.warning;
import ru.teachbase.utils.system.requestUserMediaAccess;

/**
 * Base manager for camera and mic sharing.
 *
 * Depends on RTMPManager
 *
 *
 * @author Teachbase (created: Jun 11, 2012)
 */
public class PublishManager extends Manager {

    const listener:RTMPListener = new RTMPListener(PacketType.PUBLISH, true);

    protected var _stream:NetStream;

    private var _camera:Camera;
    private var _microphone:Microphone;
    private var _connection:NetConnection;

    private var _cameraPaused:Boolean = false;
    private var _streaming:Boolean = false;

    private var _useH264:Boolean = true;
    private var _h264Settings:H264VideoStreamSettings = new H264VideoStreamSettings();
    private var _qualityId:String;

    private var _maxQuality:String = PublishQuality.HIGH;

    /**
     *  Reference to CurrentUser sharing model
     */

    private var _model:SharingModel;

    /**
     *  Create new PublishManager.
     *
     *  @inheritDoc
     */
    public function PublishManager(register:Boolean = false) {
        super(register,[RTMPManager,SessionManager]);
    }

    //------------ initialize ------------//


    override protected function initialize(reinit:Boolean = false):void {

        if (!App.rtmp || !App.rtmp.connected) {
            error("Can not find RTMPManager or RTMPManager is disconnected");
            _failed = true;
            return;
        }

        _connection = App.rtmp.connection;
        _model = App.user.sharing;

        setQuality(App.user.settings.publishQuality);

        listener.addEventListener(RTMPEvent.DATA, handleMessage);
        listener.readyToReceive = true;

        _initialized = true;
    }


    override public function clear():void{

        super.clear();
        listener.dispose();
        listener.removeEventListener(RTMPEvent.DATA, handleMessage);

    }



    //------------- API -----------------//

    /**
     *  Turn camera+mic sharing on or turn camera only sharing off.
     */

    public function toggleStartCamera():void {
        _model.enabled && ((videoSharing && closeCamera()) || start());
    }


    /**
     * Turn mic sharing on/off.
     */

    public function toggleStartAudio():void {
        ((audioSharing &&  closeAudio()) || start(true, false));
    }


    /**
     * Stop camera sharing
     * @param commit Define whether to send update message to CurrentUser model
     * @return
     */

    public function closeCamera(commit:Boolean = true):Boolean {
        if (!videoSharing)
            return false;


        _streaming && _stream.attachCamera(null);

        videoSharing = false;

        commit && statusUpdate();

        return true;
    }

    /**
     *
     * Detach audio stream (use when audio stream only!)
     *
     * @param commit Define whether to send update message to CurrentUser model
     * @return
     */

    public function closeAudio(commit:Boolean = true):Boolean {
        if (!audioSharing)
            return false;

        if(videoSharing){
            return muteAudio();
        }

        _streaming && _stream.attachAudio(null);

        audioSharing = false;

        commit && statusUpdate();

        return true;
    }


    /**
     * Close sharing
     */

    public function closeAll():void {
        closeCamera(false);
        closeAudio(false);
        statusUpdate();
    }


    /**
     *
     * Pause camera sharing
     *
     */

    public function pauseCameraSharing():void {
        _streaming && !_cameraPaused && (_cameraPaused = true) && _stream.attachCamera(null);
    }


    /**
     *
     * Resume camera sharing
     *
     */

    public function playCameraSharing():void {
       _streaming && _camera && _cameraPaused && !(_cameraPaused = false) && _stream.attachCamera(_camera);
    }


    /**
     *  Set camera quality
     *
     * @param quality
     * @default PublishQuality.MEDIUM
     * @see ru.teachbase.constants.PublishQuality
     */

    public function setQuality(quality:String):void{

        if(quality > _maxQuality) quality = _maxQuality;

        _qualityId = quality;

        switch(quality){

            case PublishQuality.LOW:
                CameraUtils.setLowQuality(_camera);
                _useH264 && _h264Settings.setProfileLevel(H264Profile.BASELINE, H264Level.LEVEL_1);
                break;
            case PublishQuality.HIGH:
                CameraUtils.setHighQuality(_camera);
                _useH264 && _h264Settings.setProfileLevel(H264Profile.MAIN, H264Level.LEVEL_3_2);
                break;
            case PublishQuality.NO_CAM:
                closeCamera();
                _camera = null;
                break;
            case PublishQuality.MEDIUM:
            default:
                CameraUtils.setMediumQuality(_camera);
                _useH264 && _h264Settings.setProfileLevel(H264Profile.MAIN, H264Level.LEVEL_3_1);
                break;
        }

        App.user.settings.publishQuality = _qualityId;

        _streaming && _stream.send('@setDataFrame','onMetaData',{quality:_qualityId});

       _useH264 && _stream && (_stream.videoStreamSettings = _h264Settings);
    }

    public function enable():void {
        _model.enabled = true;
    }

    public function disable():void {
        closeAll();
        _model.enabled = false;
    }

    //------------- API ----------------//


    /**
     *
     * Initialize camera
     *
     * @param force If <code>true</code> - re-initialize
     */

    private function setCamera(force:Boolean = false):void{

        if (_camera || !force) return;

        if(_qualityId == PublishQuality.NO_CAM){
            notify(new Notification(translate('bw_cam_not_allowed','notifications')),true);
            return;
        }

        _camera = CameraUtils.getCamera(App.user.settings.camID);

        if (!_camera) return;

        setQuality(_qualityId);

        _camera.setLoopback(true);
    }


    /**
     * Initialize microphone
     *
     * @param force If <code>true</code> - re-initialize
     */

    private function setMicrophone(force:Boolean = false):void{
        if(_microphone && !force) return;
        _microphone = MicrophoneUtils.getMicrophone(App.user.settings.micID,true);
        MicrophoneUtils.configure(_microphone);
        _microphone.gain = App.user.settings.micLevel;
    }

    /**
     *
     * Mute outgoing audio (fake audio close method).
     *
     * Only when video is on.
     *
     * @param commit
     * @return
     */


    private function muteAudio(commit:Boolean = true):Boolean {

        if (!_microphone) return false;

        _microphone.gain = 0;

        audioSharing = false;

        commit && statusUpdate();

        return true;

    }


    /**
     *
     * Unmute audio (fake audio start).
     *
     * Only when video is on.
     *
     * @param commit
     * @return
     */

    private function unmuteAudio(commit:Boolean = true):Boolean {

        if (!_microphone) return false;

        _microphone.gain = App.user.settings.volumeLevel;

        audioSharing = true;

        commit && statusUpdate();

        return true;
    }

    /**
     *
     * Start sharing
     *
     * @param audio
     * @param video
     */

    private function start(audio:Boolean = true, video:Boolean = true):void {
        if ((!audio && !video))
            return;

        // if we are streaming then do not need to check permissions

        _streaming && success(false);

        // ask for media access permissions and then publish

        !_streaming && requestUserMediaAccess(-1, -1, success, failure, App.stage);

        function success(status:Boolean):void{

            // create NetStream object if needed

            initStream();

            // if we need audio (currently we can not start camera without audio, so it is always true

            audio && ((videoSharing && unmuteAudio(false)) || startAudioSharing(false));

            // if we need video

            video && startVideoSharing(false);

            // when we starting to publish we wait 'till NetStatus.Publish.Success event to update User model

            status && (videoSharing || audioSharing) && _stream.publish('stream', App.user.sid.toString());

            // otherwise update now

            !status && statusUpdate();

        }

        function failure(error:String):void {
            warning("media access error:",error);
            audioSharing = videoSharing = false;
        }


    }

    private function startAudioSharing(commit:Boolean = true):void {

        setMicrophone(true);
        if (_microphone){
            _stream.attachAudio(null);
            _stream.attachAudio(_microphone);
            audioSharing = true;

            commit && statusUpdate();
        } else
            audioSharing = false;

    }


    private function startVideoSharing(commit:Boolean = true):void {

        setCamera(true);

        if (_camera) {

            _stream.attachCamera(_camera);

            videoSharing = true;

            commit && statusUpdate();
        } else
            videoSharing = false;

    }


    private function camActiveHandler(e:ActivityEvent):void {
        if (e.activating) {
            _camera.removeEventListener(ActivityEvent.ACTIVITY, camActiveHandler);
            _stream.attachCamera(null);
            _stream.attachCamera(_camera);
        }
    }

    protected function initStream():void {
        if (!_stream) {
            //THINK: Do we need a special connection for streams?
            _stream = new NetStream(App.rtmp.connection);
            var ns_client:Object = new Object();
            ns_client.onMetaData = function (metadata:Object):void {
                //nothing to do
            };
            _stream.client = ns_client;
            _stream.addEventListener(NetStatusEvent.NET_STATUS, streamStatusHandler);
            _stream.addEventListener(AsyncErrorEvent.ASYNC_ERROR, streamErrorHandler);
            _stream.addEventListener(IOErrorEvent.IO_ERROR, streamErrorHandler);
            _stream.bufferTime = 0;

            _useH264 && (_stream.videoStreamSettings = _h264Settings);
        }
        _streaming = true;
    }


    protected function statusUpdate():void {

        var status:uint = _model.status;

        if (status === 0 && _streaming){    // stop stream and wait for events to update status
            _stream.publish(null);
        }else{                               // update status immediately
            App.session.setShareStatus(status);
            _stream.send('@setDataFrame','onAudioVideoStatus',{hasVideo:Permissions.camAvailable(status), hasAudio:Permissions.micAvailable(status)});
        }

    }


    //------------- remote calls -----------------//


    private function remoteClose(data:Packet):void{

        const user:User = App.meeting.usersByID[data.from];

        switch(data.data.type){

            case Permissions.CAMERA:
                closeCamera();
                notify(new Notification(translate('video_stopped','notifications', user ? user.extName : translate('Admin'))),true);
                break;
            case Permissions.MIC:
                closeAudio();
                notify(new Notification(translate('audio_stopped','notifications', user ? user.extName : translate('Admin'))),true);
                break;
            default:
                closeAll();
                notify(new Notification(translate('stream_stopped','notifications', user ? user.extName : translate('Admin'))),true);
        }

    }


    //------------- handlers ----------------//

    protected function handleMessage(e:RTMPEvent):void{

        e.packet.data && e.packet.data['action'] && (this['remote'+Strings.capitalize(e.packet.data.action)] is Function) && this['remote'+Strings.capitalize(e.packet.data.action)](e.packet);

    }


    protected function streamErrorHandler(e:ErrorEvent):void {
        warning("Publish failed: ", e.text);
        _streaming = false;
        closeAll();
    }

    protected function streamStatusHandler(e:NetStatusEvent):void {

        debug("Publish: ",e.info.code);

        switch(e.info.code){
            case NetStreamStatusCodes.PUBLISH_START:{
                statusUpdate();
                _stream.send('@setDataFrame','onMetaData',{quality:_qualityId, fps:CameraUtils.DEFAULT_FPS});

                var _watcher:RTMPWatch = new RTMPWatch(_stream);
                App.rtmp.stats.registerOutput(_watcher);
                break;
            }
            case NetStreamStatusCodes.UNPUBLISH_SUCCESS:{
                videoSharing = audioSharing = false;
                _stream.close();
                _streaming  = false;
                statusUpdate();

                App.rtmp.stats.unregisterOutput();
                break;
            }
            case NetStreamStatusCodes.FAILED:{
                warning("Publish failed");
                _streaming = false;
                closeAll();

                App.rtmp.stats.unregisterOutput();
                break;
            }
        }
    }



    //----------- getter/setter --------------//


    public function get audioSharing():Boolean {
        return _model.audioSharing;
    }

    public function set audioSharing(value:Boolean):void {
        _model.audioSharing = value;
    }

    public function get videoSharing():Boolean {
        return _model.videoSharing;
    }

    public function set videoSharing(value:Boolean):void {
        _model.videoSharing = value;
    }

    public function get microphone():Microphone {
        return _microphone;
    }

    public function get camera():Camera {
        return _camera;
    }

    public function get useH264():Boolean {
        return _useH264;
    }

    public function set useH264(value:Boolean):void {
        _useH264 = value;
        setQuality(_qualityId);
    }

    public function get maxQuality():String {
        return _maxQuality;
    }

    public function set maxQuality(value:String):void {
        _maxQuality = value;
    }
}

}
