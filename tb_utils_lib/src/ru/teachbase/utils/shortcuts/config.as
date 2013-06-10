package ru.teachbase.utils.shortcuts
{
import ru.teachbase.utils.Configger;

    /**
	 * Get or set config value.
     *
     * If <code>setValue</code> is <code>undefined</code> then trying to get value;
     * otherwise trying to set value
     *
     * @param property property name (as a path)
     * @param setValue value to set.
	 */
	public function config(property:String,setValue:* = 'undefined'):*
	{
        if(setValue === 'undefined') setValue = Configger.instance.value(property);
        else
            Configger.instance.setConfigParam(property,setValue);

        return setValue;

	}
	
}