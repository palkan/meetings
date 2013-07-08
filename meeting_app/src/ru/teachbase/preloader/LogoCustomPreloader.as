package ru.teachbase.preloader {
import flash.events.Event;
import flash.events.ProgressEvent;

import mx.events.RSLEvent;
import mx.preloaders.SparkDownloadProgressBar;


/**
 *
 * Custom preloader with Teachbase logo.
 *
 * Can be controlled manually from the outside (you can show Preloader as long as you want).
 *
 */

public class LogoCustomPreloader extends SparkDownloadProgressBar {

    private var preloaderDisplay:LogoPreloader;

    private var _text:String = "";
    private var _version:String = "";

    private var _manualComplete:Boolean = false;

    private var _errorOcurred:Boolean = false;

    public function LogoCustomPreloader() {
        super();
    }


    /**
     *  Event listener for the <code>FlexEvent.INIT_COMPLETE</code> event.
     *  NOTE: This event can be commented out to stop preloader from completing during testing
     */
    override protected function initCompleteHandler(event:Event):void {
        !_manualComplete && dispatchEvent(new Event(Event.COMPLETE));
    }


    /**
     *  Creates the subcomponents of the display.
     */
    override protected function createChildren():void {
        if (!preloaderDisplay) {
            preloaderDisplay = new LogoPreloader();

            preloaderDisplay.addEventListener(Event.ADDED_TO_STAGE, function (e:Event):void {
                stage.addEventListener(Event.RESIZE, onStageResize);
                centerLoader();
            });
            preloaderDisplay.addEventListener(Event.REMOVED_FROM_STAGE, function (e:Event):void {
                stage.removeEventListener(Event.RESIZE, onStageResize);
            });

            setPreloaderLoadingText(_text);
            setVersion(_version);
            addChild(preloaderDisplay);
        }
    }


    /**
     * Event listener for the <code>ProgressEvent.PROGRESS event</code> event.
     * Download of the first SWF app
     **/
    override protected function progressHandler(evt:ProgressEvent):void {
        if (preloaderDisplay) {
            var progressApp:Number = (evt.bytesLoaded / evt.bytesTotal);

            preloaderDisplay.loadProgress(progressApp);

            setPreloaderLoadingText("loading application " + Math.round((evt.bytesLoaded / evt.bytesTotal) * 100).toString() + "%");
        } else {
            createChildren();
        }
    }

    /**
     * Event listener for the <code>RSLEvent.RSL_PROGRESS</code> event.
     **/
    override protected function rslProgressHandler(evt:RSLEvent):void {
        if (evt.rslIndex && evt.rslTotal) {

            var numberRslTotal:int = evt.rslTotal;
            var numberRslCurrent:int = evt.rslIndex;
            var rslBaseText:String = "loading RSLs (" + evt.rslIndex + " of " + evt.rslTotal + ") ";

            var progressRsl:Number = Math.round((evt.bytesLoaded / evt.bytesTotal) * 100);

            preloaderDisplay.loadProgress((evt.bytesLoaded / evt.bytesTotal));

            setPreloaderLoadingText(rslBaseText + progressRsl.toString() + "%");
        }
    }


    /**
     *  Updates the inner portion of the download progress bar to
     *  indicate initialization progress.
     */
    override protected function setInitProgress(completed:Number, total:Number):void {
        if (preloaderDisplay) {
            if (completed >= total) {
                setPreloaderLoadingText("initialized");
            } else {
                setPreloaderLoadingText("initializing " + completed + " of " + total);
            }
        }
    }

    /**
     *  Fire Preloader COMPLETE event (hide preloader)
     */

    public function complete():void {
        _manualComplete = false;
        initCompleteHandler(null);
    }

    /**
     *
     * Update status text and error status
     *
     * @param value
     * @param isError
     */

    public function setPreloaderLoadingText(value:String, isError:Boolean = false):void {
        !_errorOcurred && (preloaderDisplay.progress_txt.text = value);
        _errorOcurred = _errorOcurred || isError;
    }


    public function setVersion(value:String):void {

        preloaderDisplay.version_txt.text = value;

    }


    protected function onStageResize(e:Event):void {
        if (!preloaderDisplay) return;

        centerLoader();
    }

    private function centerLoader():void {

        try {
            stageWidth = stage.stageWidth;
            stageHeight = stage.stageHeight;
        }
        catch (e:Error) {
            stageWidth = loaderInfo.width;
            stageHeight = loaderInfo.height;
        }

        if (stageWidth == 0 && stageHeight == 0)
            return;

        var startX:Number = Math.round((stageWidth - preloaderDisplay.logo.width) / 2);
        var startY:Number = Math.round((stageHeight - preloaderDisplay.logo.height) / 2);

        preloaderDisplay.x = startX;
        preloaderDisplay.y = startY;

    }


    /**
     *
     * Preloader status text
     *
     */

    public function get text():String {
        return _text;
    }

    public function set text(value:String):void {
        _text = value;
    }


    /**
     *
     * Preloader version text
     *
     */

    public function get version():String {
        return _version;
    }

    public function set version(value:String):void {
        _version = value;
    }

    /**
     *
     * Set to true to prevent Preloader COMPLETE event
     *
     */

    public function get manualComplete():Boolean {
        return _manualComplete;
    }

    public function set manualComplete(value:Boolean):void {
        _manualComplete = value;
    }
}
}