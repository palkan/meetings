package ru.teachbase.layout
{
import mx.core.IVisualElement;

/**
	 * @author Teachbase (created: Feb 2, 2012)
	 */
	public interface ITreeLayoutElement extends IVisualElement
	{
		function get layoutIndex():String;
		function set layoutIndex(value:String):void;

		function get elementID():uint;
		function set elementID(value:uint):void;
		
		function get active():Boolean;
		function set active(value:Boolean):void;
	}
}