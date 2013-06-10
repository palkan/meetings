package ru.teachbase.utils.system
{
import flash.net.registerClassAlias;
import flash.utils.getQualifiedClassName;

/**
	 * @author Teachbase (created: May 4, 2012)
	 */
	public function registerClazzAlias(serializeOut:Class, serializeIn:Class = null):void
	{
		registerClassAlias(getQualifiedClassName(serializeOut), serializeIn || serializeOut);
		registerClassAlias(getQualifiedClassName(serializeOut).replace('::', '.'), serializeIn || serializeOut);
	}
}