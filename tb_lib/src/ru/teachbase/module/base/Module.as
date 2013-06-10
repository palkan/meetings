package ru.teachbase.module.base
{

import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.utils.getQualifiedClassName;

import mx.events.CollectionEvent;

import ru.teachbase.manage.LayoutModelManagerBase;
import ru.teachbase.model.constants.ModuleID;

/**
	 * Base IModule implementation
	 * @author Teachbase (created: Mar 2, 2012)
	 */
	public class Module extends Sprite implements IModule
	{
		/*
		protected const instances:Vector.<IModuleContent> = new Vector.<IModuleContent>();
		*/
		
		/**
		 * [instID] : IModuleContent
		 */		
		protected const instances:Object = new Object();
		
		//protected var _icon:BitmapData = new BitmapData(60, 60, false, 0xFF0000);
		protected var _icon:DisplayObject;
		protected var _iconHover:DisplayObject;
		
		private var _manager:LayoutModelManagerBase;
		
		private var _singleton:Boolean = false;
		
		private var _available:Boolean = true; 
		
		protected var _NAME:String = '';
		
		//------------ constructor ------------//
		
		public function Module(id:String)
		{
			super();
			_NAME = id;
			ModuleID.addID(this, id);
		}
		
		//------------ initialize ------------//
		
		public function initializeModule(manager:LayoutModelManagerBase):void
		{
			_manager = manager;
		}
		
		//--------------- ctrl ---------------//
		
		public function getVisual(instanceID:int):IModuleContent
		{
			const result:IModuleContent = hasInstance(instanceID) ? instances[instanceID] : instances[instanceID] = createInstance(instanceID);
			result && (result.ownerModule = this) && (this.available = false);
			return result;
		}
		
		protected function createInstance(instanceID:int):IModuleContent
		{
			if(arguments.callee === createInstance)
				throw this + '.createInstance is a template method and must be overrided.';
			return null;
		}
		
		protected function hasInstance(instanceID:int):Boolean
		{
			return  instances[instanceID];
		}
		
		//------------ get / set -------------//
		
		public function get moduleID():String
		{
			return ModuleID.getID(this);
		}
		
		private const _moduleFullID:String = getQualifiedClassName(this);
		public function get moduleFullID():String
		{
			return _moduleFullID;
		}
		
		public function get icon():DisplayObject
		{
			return _icon;
		}
		
		public function get iconHover():DisplayObject
		{
			return _iconHover;
		}
		
		protected final function get manager():LayoutModelManagerBase
		{
			return _manager;
		}

		public function get singleton():Boolean
		{
			return _singleton;
		}

		public function set singleton(value:Boolean):void
		{
			_singleton = value;
		}

		public function get available():Boolean
		{
			return _available;
		}

		public function set available(value:Boolean):void
		{
			
			var _old:Boolean = _available;
			
			if(_singleton)
				_available = value;
			
			
			if(_available != _old)
				manager.modulesCollection.dispatchEvent(new CollectionEvent(CollectionEvent.COLLECTION_CHANGE));
		}

		public function get NAME():String
		{
			return _NAME;
		}

		
		//------- handlers / callbacks -------//
		
	}
}