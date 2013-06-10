package ru.teachbase.utils.system
{
import flash.system.Capabilities;

/**
	 * Returns object containing player version information.
	 * 
	 * <b>Example:</b> {"os": "WIN", "major": 11, "minor": 4} 
	 * 
	 * @return  Object 
	 * 
	 * 
	 *  
	 */
	public function getPlayerVersion():Object
	{
		var version_str:String = Capabilities.version;
		
		var matches:Array = version_str.match(new RegExp("^(\\w{3})\\s+(\\d+),(\\d+),[\\d,]+$"));
		
		return {
			os: matches[1],
			major: parseInt(matches[2]),
			minor: parseInt(matches[3])
		};
		
	}
	
}