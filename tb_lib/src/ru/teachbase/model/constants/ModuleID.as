package ru.teachbase.model.constants
{
import flash.errors.IllegalOperationError;
import flash.utils.Dictionary;
import flash.utils.getDefinitionByName;
import flash.utils.getQualifiedClassName;

/**
	 * @author Teachbase (created: Jun 27, 2012)
	 */
	public final class ModuleID
	{
		private static const collection:Dictionary = new Dictionary(false);
		
		//------------ constructor ------------//
		
		public function ModuleID()
		{
			throw new IllegalOperationError(ModuleID + ' is an aki-static class. Use static methods.');
		}
		
		//------------ initialize ------------//
		
		//--------------- ctrl ---------------//
		
		/**
		 * 
		 * @param module: Must be a implementation of IModule: Class or instance. 
		 * 
		 */		
		public static function getID(module:Object):String
		{
			if(!(module is Class))
				module = getDefinitionByName(getQualifiedClassName(module));
			
			return collection[module] || ('unregistered:' + getQualifiedClassName(module));
		}
		
		/**
		 * <b>Override old value</b>
		 * 
		 * @param module: Must be a implementation of IModule: Class or instance.
		 * @param id: identifier for module
		 * 
		 */		
		public static function addID(module:Object, id:String):void
		{
			if(!(module is Class))
				module = getDefinitionByName(getQualifiedClassName(module));
			
			collection[module] = id;
		}
		
		//------------ get / set -------------//
		
		//------- handlers / callbacks -------//
		
	}
}