package ru.teachbase.manage
{
import flash.display.Bitmap;
import flash.display.DisplayObject;
import flash.display.MovieClip;
import flash.display.Sprite;
import flash.events.ErrorEvent;
import flash.events.Event;
import flash.utils.Dictionary;

import ru.teachbase.utils.AssetLoader;
import ru.teachbase.utils.GlobalError;
import ru.teachbase.utils.Logger;
import ru.teachbase.utils.Strings;
import ru.teachbase.utils.helpers.config;

public dynamic class SkinManager  extends Manager
	{
		
		private var _loaders:Dictionary = new Dictionary(); 
		private var _skinXML:XML;
		protected var _props:Object = new Object();
		protected var _components:Object = {};
		private var _errorState:Boolean;
		private var _urlPrefix:String = "/assets/";
		
		public function SkinManager()
		{
				super();
		}

		override protected function initialize():void{
			load(config("skin"));	
		}
		
		private function load(url:String=null):void {
			if (Strings.extension(url) == "xml" ) {
				_urlPrefix = url.substring(0, url.lastIndexOf('/'))+_urlPrefix; 
				var loader:AssetLoader = new AssetLoader();
				loader.addEventListener(Event.COMPLETE, loadComplete);
				loader.addEventListener(ErrorEvent.ERROR, loadError);
				loader.load(url);
			} else {
				GlobalError.raise("PNG skin descriptor file must have a .xml extension");
			}
		}
		
		private function loadError(evt:Event):void {
			GlobalError.raise("error occurred during loading skin XML");
		}
		
		private function loadComplete(evt:Event):void{
			var loader:AssetLoader = AssetLoader(evt.target);
			try {
				_skinXML = XML(loader.loadedObject);
				parseSkin();
			} catch (e:Error) {
				GlobalError.raise("skin: " +e.message);
			}
		}
		private function parseSkin():void{
			for each (var comp:XML in _skinXML.components.component) {
				parseConfig(comp.settings, comp.@name.toString());
				loadElements(comp.@name.toString(), comp..element);
			}
		}
		
		private function parseConfig(settings:XMLList, component:String):void {
			if (component != "") {
				if (!_props[component]) {
					_props[component] = {};
				}
				for each(var setting:XML in settings.setting) {
					_props[component][setting.@name.toString()] = setting.@value.toString();
				}
			}
		}
		
		private function loadElements(component:String, elements:XMLList):void {
			if (!component) return;
			
			for each (var element:XML in elements) {
				var newLoader:AssetLoader = new AssetLoader();
				_loaders[newLoader] = {componentName:component, elementName:element.@name.toString()};
				newLoader.addEventListener(Event.COMPLETE, elementHandler);
				newLoader.addEventListener(ErrorEvent.ERROR, elementError);
				
				newLoader.load(_urlPrefix + component+"/" + element.@src.toString());
			}
		}
		
		private function elementHandler(evt:Event):void {
			try {
				var elementInfo:Object = _loaders[evt.target];
				var loader:AssetLoader = evt.target as AssetLoader;
				var bitmap:Bitmap = loader.loadedObject as Bitmap;
				if (loader.loadedObject is Bitmap) {
					addSkinElement(elementInfo['componentName'], elementInfo['elementName'], loader.loadedObject as Bitmap);
				} else if (loader.loadedObject is MovieClip) {
					var clip:MovieClip = loader.loadedObject as MovieClip;
					if (clip.totalFrames == 1 && clip.numChildren == 1 && clip.getChildAt(0) is MovieClip && (clip.getChildAt(0) as MovieClip).totalFrames > 1) {
						addSkinElement(elementInfo['componentName'], elementInfo['elementName'], clip.getChildAt(0) as MovieClip);
					}  else {
						addSkinElement(elementInfo['componentName'], elementInfo['elementName'], clip);
					}
				}
				delete _loaders[evt.target];
			} catch (e:Error) {
				if (_loaders[evt.target]) {
					delete _loaders[evt.target];
				}
			} 
			checkComplete();
		}
		
		private function elementError(evt:ErrorEvent):void {
			if (_loaders[evt.target]) {
				delete _loaders[evt.target];
				Logger.log("skin element not loaded " + evt.text,"skin")
				checkComplete();
			} else if (!_errorState) {
				_errorState = true;
				GlobalError.raise("skin element error "+evt.text);
			}
		}
		
		private function addSkinElement(component:String, name:String, element:DisplayObject):void {	
			component = component.toLowerCase();
			if (!_components[component]) {
				_components[component] = {};
			}
			if (element is MovieClip) {
				_components[component][name] = element;
			} else {
				var sprite:Sprite = new Sprite();
				sprite.addChild(element);
				_components[component][name] = sprite;
			}
		}
		
		private function checkComplete():void {
			if (_errorState) return;
			
			var numElements:Number = 0;
			for each (var i:Object in _loaders) {
				// Not complete yet
				numElements ++;
			}
			
			if (numElements > 0) {
				return;
			}

			_initialized = true;
		}
		
		public function getSkinElement(component:String, element:String):DisplayObject {
			component = component.toLowerCase();
			if (_components[component] && _components[component][element]){
				var sprite:Sprite = _components[component][element] as Sprite;
				if (sprite.getChildAt(0) is Bitmap) {
					var bitmap:Bitmap = new Bitmap((sprite.getChildAt(0) as Bitmap).bitmapData);
					var newSprite:Sprite = new Sprite();
					newSprite.addChild(bitmap);
					bitmap.name = 'bitmap';
					return newSprite;
				} else {
					return sprite;
				}
			}
			Logger.log(component+ " " +element + " missing in styles","skin");
			return null;
		}

		public function getSkinPropertyString(component:String, propName:String):String{
			if(_props[component] && _props[component][propName]) {
				return String(_props[component][propName])
			}
			return "missing in styles";
		}
		
		
		public function getSkinPropertyNumber(component:String, propName:String):Number {
			if(_props[component] && _props[component][propName]) {
				return Number(_props[component][propName])
			}else{
				Logger.log(component+ " " +propName + " missing in styles","skin");
			}
			return 0;
		}
		
		public function hasComponent(component:String):Boolean {
			return _components.hasOwnProperty(component);
		}
	}
}