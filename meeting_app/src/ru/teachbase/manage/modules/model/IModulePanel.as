package ru.teachbase.manage.modules.model
{
import mx.core.IVisualElement;

import ru.teachbase.model.IElement;

public interface IModulePanel extends IElement, IVisualElement
	{
		function get content():IModuleContent;
        function set data(value:ModuleInstanceData):void;
        function get data():ModuleInstanceData;
		function set title(title:String):void;
        function set locked(value:Boolean):void;
        function get locked():Boolean;
        function set permissions(value:uint):void;
        function hide():void;
	}
}