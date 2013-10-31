package ru.teachbase.manage.modules.model
{

import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.utils.getQualifiedClassName;

import mx.events.CollectionEvent;

import ru.teachbase.manage.layout.LayoutManager;
import ru.teachbase.manage.modules.ModuleID;
import ru.teachbase.manage.modules.ModulesManager;
import ru.teachbase.model.App;

/**
	 * Base IModule implementation
	 * @author Teachbase (created: Mar 2, 2012)
	 */
	public class Module extends Sprite implements IModule
	{
		/**
		 * [instID] : IModuleContent
		 */		
		protected const _instances:Object = {};
		
		protected var _icon:DisplayObject;
		protected var _iconHover:DisplayObject;
		
		private var _singleton:Boolean = false;
		
		private var _available:Boolean = true; 
		
		protected var _moduleId:String = '';

        private var _manager:ModulesManager;
		
		//------------ constructor ------------//
		
		public function Module(id:String)
		{
			super();
			_moduleId = id;
			ModuleID.addID(this, id);
		}
		
		//------------ initialize ------------//
		
		public function initializeModule(manager:ModulesManager):void
		{
            _manager = manager;
        }
		
		//--------------- ctrl ---------------//
		
		public function getVisual(instanceID:int):IModuleContent
		{
			const result:IModuleContent = hasInstance(instanceID) ? _instances[instanceID] : _instances[instanceID] = createInstance(instanceID);
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
			return  _instances[instanceID];
		}
		
		//------------ get / set -------------//

		
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

            if(_singleton) _available = value;

            if(_available != _old)
				App.meeting.modulesCollection.dispatchEvent(new CollectionEvent(CollectionEvent.COLLECTION_CHANGE));
		}

		public function get moduleId():String
		{
			return _moduleId;
		}


		//------- handlers / callbacks -------//
		
	}
}