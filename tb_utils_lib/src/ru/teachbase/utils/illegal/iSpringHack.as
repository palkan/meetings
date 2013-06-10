package ru.teachbase.utils.illegal
{
import flash.display.DisplayObject;

/**
	 * A simple recursive function for removing the iSpring's watermark.
	 * <br/><b>It's magic!</b>
	 * @author Teachbase (created: Jun 1, 2012)
	 * @see http://10.101.10.111/redmine/documents/7
	 */
	public function iSpringHack(movieRoot:DisplayObject):Boolean
	{
		return testObject(movieRoot);
	}
}


import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.utils.getQualifiedClassName;

internal const TESTOR:RegExp = /ispring.resources_[^::]+[:]{2}spr[0-9]+_[0-9]*/g;

internal function testObject(o:DisplayObject, level:int = 0):Boolean
{
	if(o is DisplayObjectContainer)
	{
		const cont:DisplayObjectContainer = o as DisplayObjectContainer;
		const children:int = cont.numChildren;
	}
	
	// lookup:
	// step one
	if(cont && cont.parent && children <= 1)
	{
		// step two
		if(isTrueDefOf(cont) && isTrueDefOf(cont.parent))
		{
			o.visible = false;
			o.parent.removeChild(o);
			return true;
		}
	}
	
	// go into:
	if(cont)
	{
		for(var i:int; i < children; ++i)
		{
			if(testObject(cont.getChildAt(i), level + 1))
				return true;
		}
	}
	
	return false;
}

internal function isTrueDefOf(instance:Object):Boolean
{
	return getQualifiedClassName(instance).search(TESTOR) !== -1;
}

