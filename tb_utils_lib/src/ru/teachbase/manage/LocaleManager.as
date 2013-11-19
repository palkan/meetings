package ru.teachbase.manage
{
import flash.events.ErrorEvent;
import flash.events.Event;
import flash.system.Capabilities;

import mx.collections.ArrayList;

import ru.teachbase.error.SingletonError;
import ru.teachbase.utils.AssetLoader;
import ru.teachbase.utils.Localizer;
import ru.teachbase.utils.Strings;
import ru.teachbase.utils.helpers.toArray;
import ru.teachbase.utils.shortcuts.config;
import ru.teachbase.utils.shortcuts.cookie;
import ru.teachbase.utils.shortcuts.warning;

public class LocaleManager extends Manager
	{

        public static const instance:LocaleManager = new LocaleManager();

		private var _locale:String;
		protected var _locXML:XML;
		private var _components:Object = {};

        private var _defaultLang:String = 'ru';

        private var _availableLocales:Object = {};

		public function LocaleManager()
		{
            super();
            if(instance) throw new SingletonError();
		}
		
		override protected function initialize(reinit:Boolean = false):void{
            var locales = config('locales');

            if(locales && (locales is Array)){
                for each(var locale:Object in locales) _availableLocales[locale.code] = new LangItem(locale.code,locale.label,locale.url);

                var item:LangItem = _availableLocales[_lang] ? _availableLocales[_lang] : (_availableLocales[_defaultLang] ? _availableLocales[_defaultLang] : _availableLocales[locale.code]);

                _locale = item.code;

                load(item.url+(config('version') ? "?v="+config('version') : ''));

            }else{
                sendError('No locale provided');
            }
		}

		protected static function get _lang():String{
			return cookie('lang') || config('lang') || Capabilities.language;
		}
		
		private function load(url:String=null):void {
			var loader:AssetLoader = new AssetLoader();
			loader.addEventListener(Event.COMPLETE, loadComplete);
			loader.addEventListener(ErrorEvent.ERROR, loadError);
			loader.load(url);
		}
		
		private function loadError(evt:Event):void {
	        sendError("error occurred during loading locale XML");
		}
		
		private function loadComplete(evt:Event):void{
			var loader:AssetLoader = AssetLoader(evt.target);
			try {
				_locXML = XML(loader.loadedObject);
                parseLocale();
                initialized && sendUpdateEvent();
                !initialized && (_initialized = true);
			}catch (e:Error){
				sendError("error locale: "+e.message);
			}
		}

		private function parseLocale():void{
			_locale = _locXML.@lang;
			for each (var comp:XML in _locXML.components.component) {
				loadElements(comp.@name.toString(), comp..element);
			}
		}
		
		
		private function loadElements(component:String, elements:XMLList):void {
			if (!component) return;
			
			for each (var element:XML in elements) {
				addLocaleElement(component, element.@name, element.toString());
			}
		}
		
		private function addLocaleElement(component:String, name:String, value:String):void {	
			component = component.toLowerCase();
			if (!_components[component]) {
				_components[component] = {};
			}
			
			_components[component][name] = value;
			
		}
		
		
		public function getLocaleString(element:String,component:String):String {
			var _capital:Boolean = !(element == element.toLowerCase());
			component = component.toLowerCase();
			element = element.toLowerCase()
			if (_components[component] && _components[component][element]){
				return _capital ? Strings.capitalize(_components[component][element]) : _components[component][element];
			}
			return "";
		}
		
		
		public function hasComponent(component:String):Boolean {
			return _components.hasOwnProperty(component);
		}
		
		public static function getLocales():ArrayList{
			
			var al:ArrayList =  new ArrayList();

            for each(var item:LangItem in instance._availableLocales) al.addItem(getItem(item.label, item.code));
			return al;
		}
		
		private static function getItem(lang:String, val:String):Object {
			var obj:Object = new Object();
			obj.label = lang;
			obj.value = val;
			obj.selected = _lang == val ? true: false;
			return obj;
		}
		
		public function changeLocale(lang:String):void{
			
			if(lang === _locale || (_availableLocales[lang] == undefined))
				return;

            _locale = lang;
			load(_availableLocales[lang].url+(config('version') ? "?v="+config('version') : ''));
			
		}
		
		public static function locale():String{
			return instance._locale;
		}

        public static function localeList():Array{
            return toArray(instance._availableLocales);
        }

        private function sendError(message:String):void{
            warning(message);
            _failed = true;
        }
		
		
		private function sendUpdateEvent():void{
			Localizer.localize();
		}

}


}

internal final class LangItem{

    private var _code:String;
    private var _label:String;
    private var _url:String;

    function LangItem(code:String, label:String, url:String){
        _code = code;
        _label = label;
        _url = url;
    }


    public function get label():String {
        return _label;
    }

    public function get code():String {
        return _code;
    }

    public function get url():String {
        return _url;
    }
}