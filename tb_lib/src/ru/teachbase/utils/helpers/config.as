package ru.teachbase.utils.helpers
{
import ru.teachbase.core.App;

/**
	 * The same as <code>App.config.value(property,defaultValue);</code> 
	 */
	public function config(property:String,defaultValue:* = null):*
	{
		return App.config.value(property,defaultValue);
	}
	
}