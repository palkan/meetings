package ru.teachbase.manage
{
import flash.events.EventDispatcher;
import flash.utils.Dictionary;
import flash.utils.getQualifiedClassName;

import ru.teachbase.events.ChangeEvent;

// note:
	[Event(name="changed", type="ru.teachbase.events.ChangeEvent")]
	
	/**
	 * Base class for all core-managers.
	 * @author Teachbase (created: Jun 25, 2012)
	 */
	public class Manager
	{
		/**
		 * Cross-manager EventDispatcher
		 */		
		public static const dispatcher:EventDispatcher = new EventDispatcher();
		
		/**
		 * Fully initialized managers
		 */		
		protected static const managers:Vector.<Manager> = new Vector.<Manager>();
		
		/**
		 * Fully initialized managers : <code>Dictionary.&lt;Class&gt;[Manager]</code>
		 */		
		protected static const managersByClass:Dictionary = new Dictionary(true);
		
		/**
		 * All managers.
		 */		
		protected static const managersCollection:Vector.<Manager> = new Vector.<Manager>();
		
		private const shortName:String = getQualifiedClassName(this).replace(/.*::/, '');
		
		protected const dependencies:Array = new Array();
		
		private var __initialized:Boolean;
		private var _waitDependencies:Boolean;
		
		//------------ constructor ------------//
		
		public function Manager(dependenciesClasses:Array = null)
		{
			managersCollection.push(this);
			dependenciesClasses && dependencies.push.apply(null, dependenciesClasses);
		}
		
		//------------ initialize ------------//
		
		public final function preinitialize():void
		{
			removeInitializedDependencies();
			
			// only one time - first time:
			if(dependencies.length && !_waitDependencies)
			{
				// test, wait, continue:
				_waitDependencies = true;
				dispatcher.addEventListener(ChangeEvent.CHANGED, oneDependencyInitializedHandler);
				return;
			}
			
			// else immediately:
			if(!dependencies.length)
			{
				initialize();
				_waitDependencies = false;
			}
		}
		
		protected function initialize():void
		{
			// template method
		}
		
		private function removeInitializedDependencies():void
		{
			for(var i:int; i < dependencies.length; ++i)
			{
				var Clss:Class = dependencies[0];
				for each(var man:Manager in managers)
				{
					if(man is Clss && man.initialized)
					{
						dependencies.splice(i, 1);
						i--;
					}
				}
			}
		}
		
		//--------------- ctrl ---------------//
		
			
		public static function getManagerInstance(Clazz:Class, mustInitialized:Boolean = true):Manager
		{
			if(!(managersByClass[Clazz] is Manager))
			{
				const collection:Vector.<Manager> = mustInitialized ? managers : managersCollection;
				for each(var m:Manager in collection)
				{
					if(m is Clazz)
						return mustInitialized ? m : (managersByClass[Clazz] = m);
				}
			}
			return managersByClass[Clazz];
		}
		
		public function toString():String
		{
			return '[manager ' + shortName + (dependencies.length ? ' ( ' + dependencies + ' ) ' : '') + ']';
		}
		
		//------------ get / set -------------//
		
		public function get initialized():Boolean
		{
			return __initialized;
		}
		
		protected function set _initialized(value:Boolean):void
		{
			if(__initialized == value)
				return;
			
			managers.push(this);
			__initialized = value;
			dispatcher.dispatchEvent(new ChangeEvent(this, 'initialized', value, !value));
		}
		
		//------- handlers / callbacks -------//
		
		private function oneDependencyInitializedHandler(e:ChangeEvent):void
		{
			removeInitializedDependencies();
			preinitialize();
		}
		
		public static function disposeManagers():void{
			for each (var manager:Manager in managersCollection) {
				manager.dispose();
			}
			
			managersCollection.length = 0;
		}
		
		public function dispose():void{
			
		}
	}
}