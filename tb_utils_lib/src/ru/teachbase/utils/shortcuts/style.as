package ru.teachbase.utils.shortcuts
{
import flash.display.Bitmap;
import flash.display.Sprite;

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
            case "bitmap":
                const spr:Sprite = SkinManager.instance.getSkinElement(component,element) as Sprite;
                return (spr && spr.getChildByName('bitmap')) ? (spr.getChildByName('bitmap') as Bitmap).bitmapData : null;



		}
		
		return null;
	}
	
}