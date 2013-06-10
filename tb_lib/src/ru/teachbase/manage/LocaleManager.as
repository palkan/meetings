package ru.teachbase.manage
{
import flash.events.ErrorEvent;
import flash.events.Event;
import flash.system.Capabilities;

import mx.collections.ArrayList;

import ru.teachbase.events.SettingsEvent;
import ru.teachbase.traits.SettingsTrait;
import ru.teachbase.utils.AssetLoader;
import ru.teachbase.utils.GlobalError;
import ru.teachbase.utils.Localizer;
import ru.teachbase.utils.Strings;
import ru.teachbase.utils.helpers.config;

public class LocaleManager extends Manager
	{
		
		private const localesURL:String = config('locale_dir');
		
		private var _locale:String;
		protected var _locXML:XML;
		private var _components:Object = {};
		protected var _settingsTrait:SettingsTrait = TraitManager.instance.createTrait(SettingsTrait) as SettingsTrait;
		
		private var _defaultLang:String = "ru";
		
		private var _backToDefault:Boolean = false;
		
		public function LocaleManager()
		{
			super();
		}
		
		override protected function initialize():void{
			if(!config('locale_dir',false)) return;
			load(localesURL+_lang+".xml");	
		}
		
		protected static function get _lang():String{
			return config(SettingsEvent.LANGUAGE,Capabilities.language);
		}
		
		private function load(url:String=null):void {
			var loader:AssetLoader = new AssetLoader();
			loader.addEventListener(Event.COMPLETE, loadComplete);
			loader.addEventListener(ErrorEvent.ERROR, loadError);
			loader.load(url);
		}
		
		private function loadError(evt:Event):void {
			if(_backToDefault)
				GlobalError.raise("error occurred during loading locale XML");
			else{
				_backToDefault = true;				
				load(localesURL+_defaultLang+".xml");
			}
		}
		
		private function loadComplete(evt:Event):void{
			var loader:AssetLoader = AssetLoader(evt.target);
			try {
				_locXML = XML(loader.loadedObject);
				finalizeLoading();
			} catch (e:Error) {
				GlobalError.raise("locale: "+e.message);
			}
		}
		
		protected function finalizeLoading():void{
			parseLocale();
			initialized && sendUpdateEvent();
			_settingsTrait.addEventListener(SettingsEvent.LANGUAGE,onLocaleChanged);
			_initialized = true;
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
		
		
		public function getLocaleString(component:String, element:String):String {
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
			al.addItem(getItem("русский", "ru"));
			al.addItem(getItem("english", "en"));
			return al;
		}
		
		private static function getItem(lang:String, val:String):Object {
			var obj:Object = new Object();
			obj.label = lang;
			obj.value = val;
			obj.selected = _lang == val ? true: false;
			return obj;
		}
		
		protected function changeLocale(lang:String):void{
			
			if(lang === _locale)
				return;
			
			load(localesURL+lang+".xml");	
			
		}
		
		private function onLocaleChanged(e:SettingsEvent):void{
			changeLocale(String(e.setting.value));
		}
		
		
		public function getCurentLocale():String{
			return _locale;
		}
		
		
		
		private function sendUpdateEvent():void{

			Localizer.localize();
			
		}
		
	}
}