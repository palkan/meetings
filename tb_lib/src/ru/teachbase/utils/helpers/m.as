package ru.teachbase.utils.helpers
{
import ru.teachbase.manage.Manager;

/**
	 * @author Vova Dem (created: October 28, 2012)
	 */
	
	/**
	 * Return manager by class (if it's initialized)
	 * 
	 * @param clazz manager class
	 *  
	 */	
	
	public function m(clazz:Class):*
	{
		
		return Manager.getManagerInstance(clazz,true) as clazz;
				
	}
}