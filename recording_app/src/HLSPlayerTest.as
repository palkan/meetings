package { 


    import com.mangui.HLS.*;
    import flash.display.*;
    import flash.events.*;
    import flash.external.ExternalInterface;
    import flash.geom.Rectangle;
    import flash.media.Video;
    import flash.media.StageVideo;
    import flash.media.StageVideoAvailability;
    import flash.utils.setTimeout;

import ru.teachbase.utils.Strings;

import ru.teachbase.utils.shortcuts.debug;


public class HLSPlayerTest extends Sprite {


        /** reference to the framework. **/
        private var _hls:HLS;
        /** Sheet to place on top of the video. **/
        private var _sheet:Sprite;
        /** Reference to the video element. **/
    private var _video:StageVideo;
    private var _pause_on_playing:Boolean = true;


        /** Initialization. **/
        public function HLSPlayerTest():void {
            // Set stage properties
            stage.scaleMode = StageScaleMode.NO_SCALE;
            stage.align = StageAlign.TOP_LEFT;
            stage.fullScreenSourceRect = new Rectangle(0,0,stage.stageWidth,stage.stageHeight);
            stage.addEventListener(StageVideoAvailabilityEvent.STAGE_VIDEO_AVAILABILITY, _onStageVideoState);
            // Draw sheet for catching clicks
            _sheet = new Sprite();
            _sheet.graphics.beginFill(0x000000,0);
            _sheet.graphics.drawRect(0,0,stage.stageWidth,stage.stageHeight);
            _sheet.addEventListener(MouseEvent.CLICK,_clickHandler);
            _sheet.buttonMode = true;
            addChild(_sheet);
        }

        private function _completeHandler(event:HLSEvent):void {
            trace("Complete");
        }
        private function _errorHandler(event:HLSEvent):void {
            trace(event.message);
        }
        private function _fragmentHandler(event:HLSEvent):void {
            trace("fragment");
        }
        private function _manifestHandler(event:HLSEvent):void {
            trace("manifest");
        }

        private function _firstMediaTimeHandler(event:HLSEvent):void {
            trace("duration: "+Strings.digits(int(event.mediatime.duration)));
            _hls.removeEventListener(HLSEvent.MEDIA_TIME,_firstMediaTimeHandler);
            _hls.addEventListener(HLSEvent.MEDIA_TIME,_mediaTimeHandler);
        }

        private function _mediaTimeHandler(event:HLSEvent):void {

            trace("position: "+Strings.digits(int(event.mediatime.position)));

        }

        private function _stateHandler(event:HLSEvent):void {

            trace(event.state);

            if(_pause_on_playing && event.state == HLSStates.PLAYING){
                _hls.pause();
                _pause_on_playing = false;
            }



        }
        private function _switchHandler(event:HLSEvent):void {
        }

        /** Mouse click handler. **/
        private function _clickHandler(event:MouseEvent):void {
           _hls.pause();
        }


        /** StageVideo detector. **/
        private function _onStageVideoState(event:StageVideoAvailabilityEvent):void {
            var available:Boolean = (event.availability == StageVideoAvailability.AVAILABLE);
            if (available && stage.stageVideos.length > 0) {
              _video = stage.stageVideos[0];
              _video.viewPort = new Rectangle(0, 0, stage.stageWidth, stage.stageHeight);
              _hls = new HLS(_video);
            } else {
              var video:Video = new Video(stage.stageWidth, stage.stageHeight);
              addChild(video);
              _hls = new HLS(video);
            }
            _hls.setWidth(stage.stageWidth);
            _hls.addEventListener(HLSEvent.COMPLETE,_completeHandler);
            _hls.addEventListener(HLSEvent.ERROR,_errorHandler);
            _hls.addEventListener(HLSEvent.FRAGMENT,_fragmentHandler);
            _hls.addEventListener(HLSEvent.MANIFEST,_manifestHandler);
            _hls.addEventListener(HLSEvent.MEDIA_TIME,_mediaTimeHandler);
            _hls.addEventListener(HLSEvent.STATE,_stateHandler);
            _hls.addEventListener(HLSEvent.SWITCH,_switchHandler);



            _hls.play("http://streambox.fr/HLSProvider/playlists/test_001/stream.m3u8");
        };


    }


}