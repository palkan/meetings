package ru.teachbase.layout.model
{
import mx.core.IVisualElement;

import ru.teachbase.model.IElement;

/**
	 * @author Teachbase (created: Feb 2, 2012)
	 */
	public interface ITreeLayoutElement extends IVisualElement, IElement
	{
		function get layoutIndex():String;
		function set layoutIndex(value:String):void;
	}
}