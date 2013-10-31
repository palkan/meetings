package ru.teachbase.manage.modules.model
{
import mx.core.IVisualElement;

import ru.teachbase.components.callouts.SettingsItem;

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

        function get settings():Vector.<SettingsItem>;
		
		function get instanceID():uint;
		
		function get label():String;

		function set permissions(value:uint):void;

        function get inited():Boolean;
		
		function hide():void;
		
	}
}