package ru.teachbase.utils.helpers
{
import flash.utils.Dictionary;

/**
	 * Removes duplicates in an array.
	 * @since 1.5
	 * @param array (type must by en <code>Array</code> or any <code>Vector</code>) to remove the duplicates from.
	 * @author Teachbase (created: Dec 27, 2011)
	 */
	public function unique(array:Object):void
	{
		const contains:Dictionary = new Dictionary();
		var l: int = array.length;
		
		for(var i:int = 0; i < l; ++i)
		{
			var entry:* = array[i];
			if(contains[entry])
			{
				array.splice(i, 1);
				--i;
				--l;
			}
			else
				contains[entry] = true;
		}
	}
}