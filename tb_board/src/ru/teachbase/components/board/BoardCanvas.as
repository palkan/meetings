package ru.teachbase.components.board {
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.filters.DropShadowFilter;
import flash.geom.Rectangle;

import mx.core.IInvalidating;

import ru.teachbase.behaviours.interfaces.INotDraggle;
import ru.teachbase.components.board.model.Page;
import ru.teachbase.components.board.style.FillStyle;
import ru.teachbase.components.board.style.StrokeStyle;
import ru.teachbase.utils.shortcuts.debug;

import spark.components.ResizeMode;
import spark.core.SpriteVisualElement;

/**
 * 210 × 297 mm
 */
public final class BoardCanvas extends SpriteVisualElement implements INotDraggle {
    // A4 LANDSCAPE
    private static const WIDTH_SM:int = 300;
    private static const HEIGHT_SM:int = 225;
    private var _ratio:Number = WIDTH_SM / HEIGHT_SM;

    private var _maxCanvasWidth:Number = NaN;

    private const canvasMask:Bitmap = new Bitmap(new BitmapData(1, 1, false, 0xFFFFFF));

    private const canvasBackSprite:Sprite = new Sprite();

    private var _backgroundAlpha:Number = 1;
    private var _backgroundColor:uint = 0xffffff;

    public var cursorContainer:Sprite = new Sprite();


    /**
     * Current page
     */

    public var page:Page;

    private var _pages:Object;

    public const formatBounds:Rectangle = new Rectangle();

    public const stroke:StrokeStyle = new StrokeStyle();
    public const fill:FillStyle = new FillStyle();

    public const marginLeft:int = 0;
    public const marginTop:int = 0;

    private var _manager:FigureManager;


    private var _editable:Boolean;


    //------------ constructor ------------//

    public function BoardCanvas() {
        super();

        buttonMode =
                mouseChildren =
                        mouseEnabled = true;
        useHandCursor = false;
        doubleClickEnabled = true;
        resizeMode = ResizeMode.SCALE;

        canvasBackSprite.mouseEnabled = false;

        addChild(canvasMask);
        addChild(canvasBackSprite);

        canvasBackSprite.filters = [new DropShadowFilter(3, 45, 0, .4, 3, 3)];

        initialize();
        addChild(cursorContainer);

        // default styles:
        stroke.thickness = 1;
        stroke.alpha = 1;

    }


    public function dispose():void {
        page && page.hide();
        _pages = null;
    }


    public function clear():void{
        dispose();
        initialize();
    }


    private function initialize():void {
        _pages = {};

        var _page:Page = new Page(this, canvasMask);
        _pages[_page.pageId] = _page;

        page = _page;
        page.show();
    }



    //-------------- internal -------------//

    _figures function goToPage(id:int):void {

        page.hide();

        if (_pages[id] == undefined) {
            _pages[id] = new Page(this, canvasMask, id);
        }

        page = _pages[id];
        alignObjects();
        page.show();

        setChildIndex(cursorContainer, numChildren - 1);

    }


    _figures function getPage(id:int):Page {

        if (_pages[id] == undefined) {
            _pages[id] = new Page(this, canvasMask, id);
        }

        return (_pages[id] as Page);

    }


    _figures function setManager(mgr:FigureManager):void{

        _manager = mgr;

    }



    _figures function setStyle(id:String, value:*):void{

        if (id == "stroke")
            stroke.thickness = value;
        else if (id == "color")
            stroke.color = value;
        else if (id == "background")
            backgroundColor = value;
    }



    //--------------- ctrl ---------------//

    override protected function invalidateParentSizeAndDisplayList():void {
        super.invalidateParentSizeAndDisplayList();

        if (!includeInLayout) return;

        var p:IInvalidating = parent as IInvalidating;
        if (!p) return;

        const old:Rectangle = formatBounds.clone();
        calculateFormatBounds();
        // size changed?
        if (old.width != formatBounds.width || old.height != formatBounds.height) {
            resizeObjects();
        }
        alignObjects();
    }

    private function resizeObjects():void {
        // background & mask:
        canvasMask.width = formatBounds.width;
        canvasMask.height = formatBounds.height;

        redrawBackground();

        // canvas:
        _manager && _manager.scaleRelativeCanvasWidth(formatBounds.width);

    }

    private function redrawBackground():void {
        canvasBackSprite.graphics.clear();
        canvasBackSprite.graphics.beginFill(_backgroundColor,_backgroundAlpha);
        canvasBackSprite.graphics.drawRect(0,0,formatBounds.width,formatBounds.height);
        canvasBackSprite.graphics.endFill();
    }


    private function alignObjects():void {
        // background & mask & canvas:
        canvasBackSprite.x = canvasMask.x = page.x = cursorContainer.x = formatBounds.x;
        canvasBackSprite.y = canvasMask.y = page.y = cursorContainer.y = formatBounds.y;
    }

    private function actualizeFormatBounds():void {
        formatBounds.setTo(x + marginLeft, y + marginTop, width - 2 * marginLeft, height - 2 * marginTop);
    }


    private function calculateFormatBounds():void {
        actualizeFormatBounds();

        const original:Rectangle = formatBounds.clone();

        if (!isNaN(_maxCanvasWidth) && _maxCanvasWidth < formatBounds.width) {

            formatBounds.width = _maxCanvasWidth;

        }

        const ratio:Number = formatBounds.width / formatBounds.height;

        if (_ratio == ratio) return;

        if (_ratio < ratio){
            formatBounds.width = formatBounds.height * _ratio;
            formatBounds.x = int((original.width - formatBounds.width) / 2) + marginLeft;
        }else if (_ratio > ratio){
            formatBounds.height = formatBounds.width / _ratio;
            formatBounds.y = int((original.height - formatBounds.height) / 2) + marginTop;
        }

    }

    //------------ get / set -------------//

    public function set backgroundColor(value:uint):void {
        _backgroundColor = value;

    }


    public function set backgroundAlpha(value:Number):void {

        _backgroundAlpha = value;
        redrawBackground();
    }

    /**
     * Using for x-coords-conversations
     */
    override public function get mouseX():Number {
        return page.figureContainer.mouseX;
    }

    /**
     * Using for y-coords-conversations
     */
    override public function get mouseY():Number {
        return page.figureContainer.mouseY;
    }

    public function get editable():Boolean {
        return _editable;
    }

    public function set editable(value:Boolean):void {
        _editable = value;
    }

    public function get ratio():Number {
        return _ratio;
    }

    public function set ratio(value:Number):void {
        _ratio = value;
        invalidateParentSizeAndDisplayList();
    }

    public function get maxCanvasWidth():Number {
        return _maxCanvasWidth;
    }

    public function set maxCanvasWidth(value:Number):void {
        _maxCanvasWidth = value;
        invalidateParentSizeAndDisplayList();
    }


    //------- handlers / callbacks -------//

}
}