package ru.teachbase.utils.shortcuts
{
import ru.teachbase.utils.helpers.*;
import ru.teachbase.manage.SkinManager;

/**
	 * Return skin element.
	 * 
	 * @param component Component name/id
	 * @param element element name
	 * @type type of element (default type "" means DisplayObject; "text" - String property; "number" - Number property
	 */	
	public function style(component:String,element:String,type:String = ""):*
	{
		switch(type){
			case "":
				return SkinManager.instance.getSkinElement(component,element);
			case "string":
				return SkinManager.instance.getSkinPropertyString(component,element);
			case "number":
				return SkinManager.instance.getSkinPropertyNumber(component,element);
		}
		
		return null;
	}
	
}