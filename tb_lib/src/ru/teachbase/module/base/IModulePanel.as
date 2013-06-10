package ru.teachbase.module.base
{
import ru.teachbase.layout.ITreeLayoutElement;

public interface IModulePanel extends ITreeLayoutElement
	{
		function get currentContent():IModuleContent;
		function set content(arr:Array):void;
		function set title(title:String):void;
	}
}