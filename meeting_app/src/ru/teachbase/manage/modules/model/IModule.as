package ru.teachbase.manage.modules.model
{
import flash.display.DisplayObject;

import ru.teachbase.manage.modules.ModulesManager;

/**
	 * Must <code>extends flash.display.Sprite</code>
	 * @author Teachbase (created: Feb 20, 2012)
	 */
	public interface IModule
	{
		//------------ initialize ------------//
		
		function initializeModule(manager:ModulesManager):void;
		
		//--------------- ctrl ---------------//
		
		/**
		 * Return new or currently existing instance of this module
		 */		
		function getVisual(instance:int):IModuleContent;
		
		//------------ get / set -------------//
		
		function get moduleId():String;
		
		function get icon():DisplayObject;
		
		function set available(value:Boolean):void;
		
		function get available():Boolean;

        function get singleton():Boolean;
		
		//------- handlers / callbacks -------//
	}
}