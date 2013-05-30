package ru.teachbase.module.board.components
{
import mx.core.IVisualElement;

public interface IWBComponent extends IVisualElement
	{
		function get active():Boolean;
		function set active(value:Boolean):void;
	}
}