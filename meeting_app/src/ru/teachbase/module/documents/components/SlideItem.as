package ru.teachbase.module.documents.components
{

import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.Loader;
import flash.display.MovieClip;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.MouseEvent;
import flash.events.UncaughtErrorEvent;
import flash.geom.Point;
import flash.net.URLRequest;
import flash.system.ApplicationDomain;
import flash.system.LoaderContext;
import flash.system.Security;
import flash.system.SecurityDomain;

import mx.core.UIComponent;

import ru.teachbase.module.documents.events.CustomEvents;
import ru.teachbase.module.documents.events.MoveEvent;
import ru.teachbase.module.documents.model.SlideAsset;
import ru.teachbase.utils.logger.Logger;
import ru.teachbase.utils.StaticTextUtil;

public class SlideItem extends EventDispatcher
	{
		private var _clip:UIComponent  = new UIComponent ();
		private var _asset:SlideAsset;
		private var _isLoaded:Boolean;
		private var _ratio:Number = 1;
		private var _loader:Loader = new Loader();
		private var _movie:MovieClip;
		private var _staticTextUtil:StaticTextUtil =  new StaticTextUtil();
		private var _startHighlightingPoint:Point;
		private var _selectedText:String = "";
		private var _zoom:Number = 1;
		private var _container:Object;
		
		public function SlideItem(asset:SlideAsset, container:Object):void
		{
			_asset = asset;
			_clip.addEventListener(Event.RESIZE, resize);
			_clip.addEventListener(Event.ADDED_TO_STAGE, addedToStage)
			_container = container;
		}
		
		public function addedToStage(evt:Event):void{
			if (_movie  == null) {return;} 
			_staticTextUtil.init(_movie);
		}
		
		public function load():void{
			if (_isLoaded) {
				if (_container.onLoaded is Function) {
					_container.onLoaded();
				}
				return;
			}
			const context:LoaderContext = new LoaderContext(true, ApplicationDomain.currentDomain);
			context.allowCodeImport = true;
			context.requestedContentParent = _clip;
			if (Security.sandboxType!=Security.LOCAL_TRUSTED && Security.sandboxType!=Security.APPLICATION) context.securityDomain = SecurityDomain.currentDomain;
			
			_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loadCompleteHandler);
			try {
				_loader.load(new URLRequest(_asset.assetURL), context);
			}catch(evt:*){
				Logger.log("cant load asset "+_asset.assetURL,"slideItem");
			}
		}
				
		private function loadCompleteHandler(e:Event):void
		{
			
			//Logger.log("asset loaded"+_asset.assetURL,"slideItem");
			
			_movie = _clip.getChildAt(0) as MovieClip;
			
					
			_loader.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, handleUncaughtErrors);
			
			function handleUncaughtErrors(event:UncaughtErrorEvent):void
			{
				event.preventDefault();
			}
			
			_clip.addEventListener(MouseEvent.MOUSE_DOWN, onMouse);
			_clip.addEventListener(MouseEvent.MOUSE_UP, onMouse);
			_clip.addEventListener(MouseEvent.MOUSE_OUT, onMouse);
			_loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, loadCompleteHandler);
			
			//iSpringHack(_movie);
		
			_isLoaded = true;
			_ratio =  _loader.contentLoaderInfo.width/_loader.contentLoaderInfo.height;//_movie.width / _movie.height;
			
			_staticTextUtil.init(_movie);

			if (_container.getAllSlide is Function) {
				_container.getAllSlide(slideId+1);
			}
		}
		
		public function onMouse(evt:Event):void{
			switch (evt.type) {
				case (MouseEvent.MOUSE_DOWN):{
					_clip.addEventListener(MouseEvent.MOUSE_MOVE, onMouse);
					_staticTextUtil.clearHightlight();
					_selectedText = "";
					_startHighlightingPoint = new Point(_movie.mouseX,_movie.mouseY);
					break;
				}
				case (MouseEvent.MOUSE_UP || MouseEvent.MOUSE_OUT):
				{
					_clip.removeEventListener(MouseEvent.MOUSE_MOVE, onMouse);
					break
				}
				case (MouseEvent.MOUSE_MOVE):{
					dispatchEvent(new MoveEvent(CustomEvents.MOVE_EVENT,new Point()));
					_selectedText = _staticTextUtil.getTextByDelta(_startHighlightingPoint,new Point(_movie.mouseX,_movie.mouseY));
					break;
				}
			}
		}
		
		
		
		public function get clip():UIComponent  {
			return _clip;
		}
		
		public function zoomTo(val:Number):void{
			if (_zoom == val) 
				return;
		}
		
		public function get rotation():Number {
			if (_clip)
				return _clip.rotation;
			else
				return 0;
		}
		
		public function get zoom():Number{
			return 0;	
		}
		
		public function get slideId():int {
			return _asset.id;
		}
		
		public function get ratio():Number {
			return _ratio;
		}
		
		public function play():void{
			if(_movie == null){return};
			fakeClick(_movie);
		}
		
		private function fakeClick(ob:DisplayObject):void{
			if (ob.hasEventListener("click")) {
				ob.dispatchEvent(new MouseEvent(MouseEvent.CLICK));
				return;
			}
			if (ob is DisplayObjectContainer){
				const obC:DisplayObjectContainer = ob as DisplayObjectContainer;
				for (var i:int; i< obC.numChildren; i++){
					fakeClick(obC.getChildAt(i));
				}
			}
		}
		
		private function resize(evt:Event):void{
			if (!_movie) {return;}
			_movie.width = _clip.width;
			_movie.height = _clip.height;
					
		}
		
		public function dispose():void{
			if (_clip != null) {
				_clip.removeEventListener(Event.RESIZE, resize);
				_clip.removeEventListener(Event.ADDED_TO_STAGE, addedToStage);
			}
			if (_clip) { 
				_clip.removeEventListener(MouseEvent.MOUSE_DOWN, onMouse);
				_clip.removeEventListener(MouseEvent.MOUSE_UP, onMouse);
				_clip.removeEventListener(MouseEvent.MOUSE_OUT, onMouse);
				_clip.removeEventListener(MouseEvent.MOUSE_MOVE, onMouse);
				_clip = null;
			}
			if (_loader) {
				_loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, loadCompleteHandler);
			}
			_movie = null;
			_clip = null;
			if (_staticTextUtil) {
				_staticTextUtil.dispose();
			}
			_staticTextUtil = null;
		}
		
		public function startDrag():void{
			_clip.startDrag();
		}
		
		public function stopDrag():void{
			_clip.stopDrag();
		}
	}
}
