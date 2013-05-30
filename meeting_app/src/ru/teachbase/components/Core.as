package ru.teachbase.core
{
import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.events.ErrorEvent;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.ui.Keyboard;

import mx.core.IFlexDisplayObject;
import mx.core.IVisualElement;
import mx.core.IVisualElementContainer;
import mx.managers.PopUpManager;

import ru.teachbase.components.Console;
import ru.teachbase.events.ChangeEvent;
import ru.teachbase.events.CoreEvent;
import ru.teachbase.manage.LocaleManager;
import ru.teachbase.manage.Manager;
import ru.teachbase.utils.Configger;
import ru.teachbase.utils.logger.Logger;
import ru.teachbase.utils.shortcuts.config;

import spark.components.Group;
import spark.events.ElementExistenceEvent;

/**
	 * @author Teachbase (created: Jun 18, 2012)
	 */
	[Event(name="coreComplete", type="ru.teachbase.events.CoreEvent")]
	[Event(name="coreError", type="ru.teachbase.events.CoreEvent")]
	[Event(name="loadingStatus", type="ru.teachbase.events.CoreEvent")]
	
	public class Core extends Group
	{
		private static const topLayer:Vector.<IVisualElement> = new Vector.<IVisualElement>();
		
		public static var instance:Core;
		
		public var mode:String = 'web';	
	
		public var conf:String;
		
		public var mandatoryFields:String = '';
		
		private var _console:Console;
		
		public var defaults:Object;
		private var _initilized:Boolean;
		
		//------------ constructor ------------//
		private var _tasks:Vector.<Function>;
		
		public function Core()
		{
			instance = this;
			super();
		}
		
		//------------ initialize ------------//
		
		override public function initialize():void
		{
			if (_initilized)
				return
			_initilized = true;
			Configger.CONFIG_URL = conf;
			
			defaults && App.config.setDefaults(defaults);
			
			App.config.addEventListener(Event.COMPLETE,onConfigComplete);
			App.config.addEventListener(ErrorEvent.ERROR,onConfigError);
			
			App.config.loadConfig();
			
		}
				
		
		//--------------- ctrl ---------------//
		
		override protected function createChildren():void
		{
			super.createChildren();
			
			addEventListener(ElementExistenceEvent.ELEMENT_ADD, childAddedHandler);
			validateTopLayer();
		}
		
		private function inTheTopLayer(o:Object):Boolean
		{
			return instance && o && topLayer.indexOf(o) !== -1;
		}
		
		private function validateTopLayer():void
		{
			if(instance)
			for(var i:int; i < topLayer.length; ++i)
			{
				var index:uint = numElements + i;
				if(contains(topLayer[i] as DisplayObject) && getElementIndex(topLayer[i]) !== index)
					setElementIndex(topLayer[i], index-1);
				else
					addElementAt(topLayer[i], index);
			}
		}
		
		public static function addToTop(child:IVisualElement):void
		{
			const index:int = topLayer.indexOf(child);
			
			if(instance && index === -1)
				topLayer.push(child) && instance.validateTopLayer();
		}
		
		public static function addPopupToTop(child:IFlexDisplayObject,parent:DisplayObject = null):void{
			PopUpManager.addPopUp(child,parent ? parent: instance,true);
		}
		
		public static function removePopupFromTop(child:IFlexDisplayObject):void{
			PopUpManager.removePopUp(child);
		}
		
		public static function removeFromTop(child:IVisualElement):void
		{
			const index:int = topLayer.indexOf(child);
			
			if(instance && index !== -1)
				topLayer.splice(index, 1);
			
			if(instance.contains(child as DisplayObject))
			{
				if(child.parent is IVisualElementContainer)
					(child.parent as IVisualElementContainer).removeElement(child);
				else
					(child.parent as DisplayObjectContainer).removeChild(child as DisplayObject);
			}
		}
		
		//------------ get / set -------------//
		
		
		
		//------- handlers / callbacks -------//
		
		private final function childAddedHandler(e:ElementExistenceEvent):void
		{
			if(!inTheTopLayer(e.element))
				validateTopLayer();
		}
		
		
		private function onConfigError(e:ErrorEvent):void{
			dispatchEvent(new CoreEvent(CoreEvent.CORE_LOAD_ERROR,true,false,"Error while loading config", true));
			//GlobalError.raise("failed to load config");
			
		}
		
		
		
		private function checkMandatoryFields():Boolean{
			
			for each(var key:String in mandatoryFields.split(",")){
				
				if(config(key,undefined) == undefined)
					return false;
				
			}
			
			return true;
		}
		
		
		private function onConfigComplete(e:Event):void{
			
			if(!checkMandatoryFields()){
				dispatchEvent(new CoreEvent(CoreEvent.CORE_LOAD_ERROR,true,false,"Bad configuration: "+conf, true));
				return;
				//throw new IllegalOperationError("Bad configuration: "+conf);
			}
			
			if(_tasks)
				return;
			
			_tasks = new Vector.<Function>();
			
			if(config("lang",false)){
				_tasks.push(initLocale);
			}
						
			
			if(config("service",false)){
				_tasks.push(initService);	
			}
			
			
			///runTasks();			
			super.initialize();
		}
		
		
		
		
		
		public function runTasks():void{
			if(_tasks.length > 0){
				var _t:Function = _tasks.shift();
				_t();			
			}
		}
		
		private function initLocale():void{
			dispatchEvent(new CoreEvent(CoreEvent.LOADING_STATUS,true,false,"Initing locale..."));
			
			var locM:LocaleManager = new LocaleManager();
			Manager.dispatcher.addEventListener(ChangeEvent.CHANGED,localeInited);
			function localeInited(e:ChangeEvent):void{
				if(e.property === 'initialized'){
					Manager.dispatcher.removeEventListener(ChangeEvent.CHANGED,localeInited);
					runTasks();
				}
			}
			
			locM.preinitialize();
			
		}
		
		
		private function initService():void{
			dispatchEvent(new CoreEvent(CoreEvent.LOADING_STATUS,true,false,"Connecting to server..."));
			App.service.initialize();
			App.service.connect();
			
			runTasks();
		}
		
		
		public function setupConsole():void{
			
			_console = new Console();
			
			_console.percentWidth = 100;
			_console.percentHeight = 30;
			
			_console.visible = false;
			
			
			Logger.console = _console;
			
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyPressed);
			
		}
		
		
		protected function onKeyPressed(event:KeyboardEvent):void{
			
			switch(event.keyCode){
				
				case Keyboard.F12:
				{
					if(_console.visible){
						
						removeFromTop(_console);
						_console.visible = false;
						
					}else{
						
						addToTop(_console);
						_console.visible = true;
					}
					
					break;
				}
					
			}
			
		}
		
		
		
	}
}