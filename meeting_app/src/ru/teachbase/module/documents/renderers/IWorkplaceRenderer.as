package ru.teachbase.module.documents.renderers
{
import mx.core.IVisualElement;
import mx.core.IVisualElementContainer;

import ru.teachbase.utils.interfaces.IDisposable;

import spark.components.Group;

public interface IWorkplaceRenderer extends IDisposable,IVisualElement
	{
		
		
		function get hasControls():Boolean;
		
		function get useWB():Boolean;
		
		function get ratio():Number;
		
		function get initialWidth():Number;
		
		function get editable():Boolean;
		
		function set editable(value:Boolean):void;
		
		function set data(value:Object):void;

        function get data():Object;
		
		function resize(w:Number,h:Number):void;
		
		function zoom(flag:Boolean):void;
		
		function rotate(flag:Boolean):void;
		
		function initControls(container:IVisualElementContainer):Boolean;
		
		function initParent(container:Group):Boolean;
		
	}
}
