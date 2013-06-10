package ru.teachbase.utils.helpers
{
import flash.utils.getQualifiedClassName;

/**
	 * @author Teachbase (created: Mar 11, 2012)
	 */
	public function isList(o:*):Boolean
	{
		const type:String = getQualifiedClassName(o);
		if(type.indexOf(VECTOR_CLASS_NAME) !== -1)
			return true;
		
		if(listTypes.indexOf(type))
			return true;
		
		return false;
	}
}

internal const listTypes:Vector.<String> = Vector.<String>(['Object', 'Array', 'XML', 'XMLList']);
