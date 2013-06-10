package ru.teachbase.utils
{
import flash.errors.IllegalOperationError;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.utils.getQualifiedClassName;

import ru.teachbase.events.ChangeEvent;
import ru.teachbase.events.InitilizeEvent;
import ru.teachbase.manage.Manager;
import ru.teachbase.model.constants.OperationKind;

[Event(name="complete", type="flash.events.Event")]
	[Event(name="error", type="flash.events.ErrorEvent")]
	
	/**
	 * @author Teachbase (created: Jun 25, 2012)
	 */
	public final class Initializer extends EventDispatcher
	{
		public static const instance:Initializer = new Initializer();
		
		/**
		 * [index] = Manager instance or Manager SubClass
		 */		
		private static const managersToDo:Array = new Array();
		
		private static var _complete:Boolean;
		
		//------------ constructor ------------//
		
		public function Initializer()
		{
			if(instance)
				throw new IllegalOperationError(this + ' is a Singleton. Use static methods and properties.');
		}
		
		//------------ initialize ------------//
		
		/**
		 * 
		 * @param kind see OperationKind constants. <br/>
		 * Default value = <code>OperationKind.SEQUENCE</code>.
		 * @param managers classes for init
		 * 
		 */		
		public function initializeManagers(kind:String, ...managers):void
		{
			if(kind === OperationKind.PARALLEL)
				initializeParallel(managers);
			else
				initializeSequence(managers);
		}
		
		private function initializeParallel(managers:Array):void
		{
			Shared.DISPATCHER.addEventListener(ChangeEvent.CHANGED, anyModuleChangingsHandler);
			
			var ManagerClass:Class;
			var manager:Manager;
			
			// copy:
			managersToDo.push.apply(null, managers);
			
			// start init:
			for(var i:int; i < managersToDo.length; ++i)
			{
				ManagerClass = managersToDo[i] as Class;
				managersToDo[i] = manager = new ManagerClass();
				manager.preinitialize();
				
				if(manager.initialized)
					i--;
			}
		}
		
		private function initializeSequence(managers:Array):void
		{
			Shared.DISPATCHER.addEventListener(ChangeEvent.CHANGED, anyModuleChangingsHandler);
			
			managersToDo.push.apply(null, managers);
			
			// start init:
			initilizeNext();
		}
		
		private function initilizeNext():void{
			if(managersToDo && managersToDo.length){
				var ManagerClass:Class  = managersToDo[0] as Class;
				managersToDo[0] = new ManagerClass();
				dispatchEvent(new InitilizeEvent(InitilizeEvent.MANAGER_IS_INITILIZE, Strings.convertQualifideClassNameToString(getQualifiedClassName(managersToDo[0]))));
				managersToDo[0].preinitialize();
			}
		}
		
		//--------------- ctrl ---------------//
		
		//------------ get / set -------------//
		
		public function get complete():Boolean
		{
			return _complete;
		}
		
		//------- handlers / callbacks -------//
		
		private function anyModuleChangingsHandler(e:ChangeEvent):void
		{
			if(e.property !== 'initialized' || !e.value){
				trace(e.property,e.value);
				return;
			}
			
			const index:int = managersToDo.indexOf(e.host);
			if(index !== -1)
				managersToDo.splice(index, 1);
			
			//Logger.log('manager initialized:', e.host.toString());
			
			if(!managersToDo.length)
			{
				_complete = true;
				Shared.DISPATCHER.removeEventListener(ChangeEvent.CHANGED, anyModuleChangingsHandler);
				dispatchEvent(new Event(Event.COMPLETE));
			}
			else {
				initilizeNext();
			}
		}
		
	}
}


import flash.events.EventDispatcher;
import flash.utils.Dictionary;

import ru.teachbase.manage.Manager;

internal class Shared extends Manager
{
	public static function get DISPATCHER():EventDispatcher
	{
		return dispatcher;
	}
	
	public static function get MANAGERS():Vector.<Manager>
	{
		return managers;
	}
	
	public static function get MANAGERS_BY_CLASS():Dictionary
	{
		return managersByClass;
	}
}

