package ru.teachbase.manage {
import flash.events.ActivityEvent;
import flash.events.AsyncErrorEvent;
import flash.events.ErrorEvent;
import flash.events.IOErrorEvent;
import flash.events.NetStatusEvent;
import flash.media.Camera;
import flash.media.Microphone;
import flash.media.MicrophoneEnhancedMode;
import flash.media.MicrophoneEnhancedOptions;
import flash.media.SoundCodec;
import flash.net.NetConnection;
import flash.net.NetStream;

import ru.teachbase.constants.NetStreamStatusCodes;

import ru.teachbase.events.PermissionEvent;
import ru.teachbase.events.SettingsEvent;
import ru.teachbase.manage.rtmp.RTMPManager;
import ru.teachbase.model.App;
import ru.teachbase.model.CameraSettings;
import ru.teachbase.model.SharingModel;
import ru.teachbase.utils.Permissions;
import ru.teachbase.utils.shortcuts.config;
import ru.teachbase.utils.shortcuts.debug;
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

    protected var _stream:NetStream;

    protected var _camera:Camera;
    protected var _microphone:Microphone;
    private var _connection:NetConnection;

    private var _cameraPaused:Boolean = false;
    private var _streaming:Boolean = false;

    /**
     *  Reference to CurrentUser sharing model
     */

    private var _model:SharingModel;

    /**
     *  Create new PublishManager.
     *
     * @param usePermissions    defines whether to handle permissions events
     * @param useSettings        defines whether to handle settings events
     * @param deps                dependencies
     *
     */
    public function PublishManager(usePermissions:Boolean = false, useSettings:Boolean = false) {
        super([RTMPManager,SessionManager]);
    }

    //------------ initialize ------------//


    override protected function initialize():void {

        if (!App.rtmp || !App.rtmp.connected) {
            _failed = true;
            return;
        }

        _connection = App.rtmp.connection;
        _model = App.user.sharing;
        _initialized = true;
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
        _model.enabled && ((audioSharing &&  closeAudio()) || start(true, false));
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

    public function closeAll():void {
        closeCamera(false);
        closeAudio(false);
        statusUpdate();
    }


    public function pauseCameraSharing():void {
        _streaming && !_cameraPaused && (_cameraPaused = true) && _stream.attachCamera(null);
    }

    public function playCameraSharing():void {
       _streaming && _camera && _cameraPaused && !(_cameraPaused = false) && _stream.attachCamera(_camera);
    }


    public function setQuality():void{
        //TODO
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

        _microphone.gain = App.user.settings.volume;

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


        if (setMicrophone()) {
            _stream.attachAudio(null);
            _stream.attachAudio(_microphone);
            audioSharing = true;

            commit && statusUpdate();
        } else
            audioSharing = false;

    }


    private function startVideoSharing(commit:Boolean = true):void {

        if (setCamera()) {

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
        if (_stream == null) {
            //THINK: Do we need a special connection for streams?
            _stream = new NetStream(App.rtmp.connection);
            var ns_client:Object = new Object();
            ns_client.onMetaData = function (metadata:Object):void {
                //nothing to do
            };
            _stream.client = ns_client;
            _stream.addEventListener(NetStatusEvent.NET_STATUS, nsPublishOnStatus);
            _stream.addEventListener(AsyncErrorEvent.ASYNC_ERROR, onError);
            _stream.addEventListener(IOErrorEvent.IO_ERROR, onError);
            _stream.bufferTime = 0;
        }
        //TODO: move this code to NetStatus handler
        _streaming = true;
    }


    protected function statusUpdate():void {

        var status:uint = _model.status;

        if (status === 0 && _streaming){    // stop stream and wait for events to update status
            _stream.dispose();
            _streaming = false;
        }else                               // update status immediately
            App.user.shareStatus = status;

    }


    //------------ get / set -------------//


    private function setCamera(force:Boolean = false):Camera {

        if (!videoSharing || force) {
            _camera = Camera.getCamera(config(SettingsEvent.CAMERA_ID, null));
            if (!_camera) {
                _camera = Camera.getCamera();
            }

            if (!_camera) return null;

            CameraSettings.setPreset(_camera, _stream, config(SettingsEvent.CAMERA_QUALITY, CameraSettings.PRESET2));
            //camera.setKeyFrameInterval(4);
            _camera.setLoopback(true);
        }

        return _camera;

    }


    protected function setMicrophone(force:Boolean = false):Microphone {
        if (!audioSharing || force) {
            var options:MicrophoneEnhancedOptions = new MicrophoneEnhancedOptions();
            options.mode = MicrophoneEnhancedMode.FULL_DUPLEX;
            options.echoPath = 128;
            options.nonLinearProcessing = true;
            _microphone = Microphone.getEnhancedMicrophone(int(config(SettingsEvent.MICROPHONE_ID, -1)));
            if (!_microphone) {
                _microphone = Microphone.getEnhancedMicrophone()
            }

            if (!_microphone) return null;

            _microphone.enhancedOptions = options;
            _microphone.gain = config(SettingsEvent.MICROPHONE_VOLUME, 80);
            _microphone.codec = SoundCodec.SPEEX;
            _microphone.framesPerPacket = 2;
            _microphone.rate = 11;
            _microphone.setSilenceLevel(0);
            _microphone.encodeQuality = 5;
            _microphone.setLoopBack(false);
            _microphone.setUseEchoSuppression(true);
        }


        return _microphone;
    }

    protected function onError(e:ErrorEvent):void {

        warning("io error", "camerashare");

    }

    protected function nsPublishOnStatus(e:NetStatusEvent):void {

        debug("Publish: ",e.info.code);

        switch(e.info.code){
            case NetStreamStatusCodes.PUBLISH_START:
                statusUpdate();
                break;
            case NetStreamStatusCodes.UNPUBLISH_SUCCESS:
            case NetStreamStatusCodes.FAILED:
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

}

}
