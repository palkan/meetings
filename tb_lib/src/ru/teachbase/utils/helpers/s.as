package ru.teachbase.utils.helpers
{
import ru.teachbase.manage.SkinManager;

/**
	 * Return skin element.
	 * 
	 * @param component Component name/id
	 * @param element element name
	 * @type type of element (default type "" means DisplayObject; "text" - String property; "number" - Number property
	 */	
	public function s(component:String,element:String,type:String = ""):*
	{
		switch(type){
			case "":
				return (m(SkinManager) as SkinManager).getSkinElement(component,element);
			case "string":
				return (m(SkinManager) as SkinManager).getSkinPropertyString(component,element);
			case "number":
				return (m(SkinManager) as SkinManager).getSkinPropertyNumber(component,element);
		}
		
		return null;
	}
	
}