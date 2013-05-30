package ru.teachbase.module.base
{
import flash.display.DisplayObject;

import ru.teachbase.manage.LayoutManager;

/**
	 * Must <code>extends flash.display.Sprite</code>
	 * @author Teachbase (created: Feb 20, 2012)
	 */
	public interface IModule
	{
		//------------ initialize ------------//
		
		function initializeModule(manager:LayoutManager):void;
		
		//--------------- ctrl ---------------//
		
		/**
		 * Return new or currently existing instance of this module
		 */		
		function getVisual(instance:int):IModuleContent;
		
		//------------ get / set -------------//
		
		function get moduleID():String;
		
		function get icon():DisplayObject;
		
		function set available(value:Boolean):void;
		
		function get available():Boolean;
		
		//------- handlers / callbacks -------//
	}
}