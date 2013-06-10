package ru.teachbase.manage.modules.model
{
import mx.core.IVisualElement;

/**
	 * Any module's content must implement this interface.
	 * @author Teachbase (created: Mar 2, 2012)
	 */
	public interface IModuleContent extends IVisualElement
	{
		function get ownerModule():IModule;
		function set ownerModule(owner:IModule):void;
		
		function get ownerPanel():IModulePanel;
		function set ownerPanel(owner:IModulePanel):void;
		
		function get panelID():uint;
		function set panelID(value:uint):void;
		
		function get instanceID():uint;
		
		function get label():String;

		function set p_enabled(value:Boolean):void;
		
		function hide():void;
		
	}
}