package ru.teachbase.utils.shortcuts
{
import ru.teachbase.manage.LocaleManager;
import ru.teachbase.utils.Strings;

/**
	 * @author Vova Dem (created: October 25, 2012)
	 */
	
	/**
	 * Return text according to current locale.
	 * 
	 * @param component Component name/id
	 * @param name Name of field
	 * @param ...args Arguments to pass to the resulting string;<br/>
	 * locale string must contain variables' placeholders of the type <i>${i}</i>, where <i>i</i> is an index of argument (begin with 1)
	 * <br/>
	 * <b>Example</b><br/>
	 * <code>
	 * l('user_is_fool','global','Ivan');
	 * </code>
	 * work the following way:
	 * <ul>
	 * <li> get locale string "#{1} is fool!"</li>
	 * <li> replace "#{1}" with "Ivan"</li>
	 * <li> return "Ivan is fool!"</li>
	 * </ul>
	 */	
	
	public function translate(name:String,component:String = "global",...args):String
	{
		return Strings.interpolate(LocaleManager.instance.getLocaleString(name,component),args);
	}
}