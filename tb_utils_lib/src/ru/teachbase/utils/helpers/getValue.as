package ru.teachbase.utils.helpers
{
	
	/**
	 * @author Vova Dem (created: October 15, 2012)
	 */
	
	/**
	 * Return the value of an object <i>object</i> with the key <i>key</i> if such exists and satisfies verification function (<i>veriFunction</i>); 
	 * Otherwise return default value.
	 *
     * @param target
     * @param key
     * @param defaultValue
	 * @param veriFunction  Should be Boolean function with one argument (target[key])
	 */	
	
	public function getValue(target:Object,key:String,defaultValue:* = null, veriFunction:Function = null):*
	{
				
		
		if(target && target[key]!=undefined && (!(veriFunction as Function) || veriFunction(target[key])))
			return target[key];
		else
			return defaultValue;
		
	}
}