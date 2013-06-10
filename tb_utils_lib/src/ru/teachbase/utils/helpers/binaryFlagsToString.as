package ru.teachbase.utils.helpers
{

	/**
	 * @author Teachbase (created: May 4, 2012)
	 */
	public function binaryFlagsToString(value:uint, identity:Object, braces:Boolean = false, separator:String = ','):String
	{
		if(!identity)
			return '[' + value.toString(2) + ']';
		
		var results:Array = [];
		
		for(var name:String in identity)
		{
			if(value & identity[name])
				results.push(name);
		}
		
		if(!results.length)
			results.push(value.toString(2));
		
		if(braces)
			return '[' + results.join(separator) + ']';
		else
			return results.join(separator);
	}
}