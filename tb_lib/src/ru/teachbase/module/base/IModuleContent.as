package ru.teachbase.module.base
{
import mx.core.IVisualElement;

import ru.teachbase.model.ModuleSettings;

/**
	 * Any module's content must implement this interface.
	 * @author Teachbase (created: Mar 2, 2012)
	 */
	public interface IModuleContent extends IVisualElement
	{
		//------------ initialize ------------//
		
		//--------------- ctrl ---------------//
		
		//------------ get / set -------------//
		
		/**
		 * @private
		 */		
		function get ownerModule():IModule;
		function set ownerModule(owner:IModule):void;
		
		function get ownerPanel():IModulePanel;
		function set ownerPanel(owner:IModulePanel):void;
		
		function get panelID():uint;
		function set panelID(value:uint):void;
		
		function get instanceID():uint;
		
		function get label():String;
		
		/**
		 * 
		 * Use to make changes in view depending on user's role
		 * 
		 * If user is not admin then available is set to <i>false</i>
		 * 
		 */
				
		function set permission(value:int):void;
		
		function get settings():Vector.<ModuleSettings>;
		
		function hideContainer():void;
		
		//------- handlers / callbacks -------//
	}
}