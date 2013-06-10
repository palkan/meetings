package ru.teachbase.utils.helpers
{
	
	/**
	 * @author Teachbase (created: Mar 11, 2012)
	 */
	public function toArray(obj:Object):Array
	{
		if(!obj) 
			return null;
		
		const result:Array = [];
		
		for each(result[result.length] in obj);
		
		return result;
	}
}