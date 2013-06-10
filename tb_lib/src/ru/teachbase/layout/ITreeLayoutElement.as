package ru.teachbase.layout
{
import mx.core.IVisualElement;

/**
	 * @author Teachbase (created: Feb 2, 2012)
	 */
	public interface ITreeLayoutElement extends IVisualElement
	{
		//------------ initialize ------------//
		//--------------- ctrl ---------------//
		
		//------------ get / set -------------//
		
		function get layoutIndex():String;
		function set layoutIndex(value:String):void;
		
		function get privacy():Boolean;
		function set privacy(value:Boolean):void;
		
		function get elementID():uint;
		function set elementID(value:uint):void;
		
		function get active():Boolean;
		function set active(value:Boolean):void;
		
		
		function set permission(value:int):void;
		
		//------- handlers / callbacks -------//
	}
}