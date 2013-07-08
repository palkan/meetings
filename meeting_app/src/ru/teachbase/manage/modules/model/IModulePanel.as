package ru.teachbase.manage.modules.model
{
import mx.core.IVisualElement;

import ru.teachbase.model.IElement;

public interface IModulePanel extends IElement, IVisualElement
	{
		function get currentContent():IModuleContent;
		function set content(arr:Array):void;
		function set title(title:String):void;
        function set locked(value:Boolean):void;
        function get locked():Boolean;
	}
}