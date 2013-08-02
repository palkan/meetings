package ru.teachbase.utils {
	
	/**
	 * This class groups a couple of commonly used string operations.
	 * @author Jeroen Wijering, palkan
	 **/
	public class Strings {

		
		public static function capitalize(str:String):String{
			if(str.length<=1) return str.toUpperCase();
			
			return str.charAt(0).toUpperCase()+str.slice(1);
		}
		
		/**
		 * Convert a number to a digital-clock like string.
		 *
		 * @param nbr	The number of seconds.
         * @param hours Try to represent hours (if minutes > 59).
		 * @return		A (HH)?:MN:SS string.
		 **/
		public static function digits(nbr:Number,hours:Boolean = false):String {
			var min:Number = (nbr / 60)|0;
			var sec:Number = (nbr % 60)|0;
			var hrs_s:String = '';

            if(hours && min > 59) hrs_s = Strings.zero((min / 60)|0)+':', min = min % 60;

            return hrs_s+Strings.zero(min) + ':' + Strings.zero(sec);
		}
		
		/**
		 * Convert a time-representing string to a number.
		 *
		 * @param str	The input string. Supported are 00:03:00.1 / 03:00.1 / 180.1s / 3.2m / 3.2h
		 * @return		The number of seconds.
		 **/
		public static function seconds(str:String):Number {
			str = str.replace(',', '.');
			var arr:Array = str.split(':');
			var sec:Number = 0;
			if (str.substr(-2) == 'ms') {
				sec = Number(str.substr(0, str.length - 2)) / 1000;
			} else if (str.substr(-1) == 's') {
					sec = Number(str.substr(0, str.length - 1));
			} else if (str.substr(-1) == 'm') {
				sec = Number(str.substr(0, str.length - 1)) * 60;
			} else if (str.substr(-1) == 'h') {
				sec = Number(str.substr(0, str.length - 1)) * 3600;
			} else if (arr.length > 1) {
				sec = Number(arr[arr.length - 1]);
				sec += Number(arr[arr.length - 2]) * 60;
				if (arr.length == 3) {
					sec += Number(arr[arr.length - 3]) * 3600;
				}
			} else {
				sec = Number(str);
			}
			return sec;
		}
		
		/**
		 * Basic serialization: string representations of booleans and numbers are returned typed;
		 * strings are returned urldecoded.
		 *
		 * @param val	String value to serialize.
		 * @return		The original value in the correct primitive type.
		 **/
		public static function serialize(val:String):Object {
			if (val == null) {
				return null;
			} else if (val == 'true') {
				return true;
			} else if (val == 'false') {
				return false;
			} else if (isNaN(Number(val))) {
				return val;
			} else {
				return Number(val);
			}
		}
		
		/**
		 * Strip HTML tags and linebreaks off a string.
		 *
		 * @param str	The string to clean up.
		 * @return		The clean string.
		 **/
		public static function strip(str:String):String {
			var tmp:Array = str.split("\n");
			str = tmp.join("");
			tmp = str.split("\r");
			str = tmp.join("");
			var idx:Number = str.indexOf("<");
			while (idx != -1) {
				var end:Number = str.indexOf(">", idx + 1);
				end == -1 ? end = str.length - 1 : null;
				str = str.substr(0, idx) + "" + str.substr(end + 1, str.length);
				idx = str.indexOf("<", idx);
			}
			return str;
		}
		
		/**
		 * Add a leading zero to a number.
		 *
		 * @param nbr	The number to convert. Can be 0 to 99.
		 * @ return		A string representation with possible leading 0.
		 **/
		public static function zero(nbr:Number):String {
			if (nbr < 10) {
				return '0' + nbr;
			} else {
				return '' + nbr;
			}
		}
		/**
		 * Finds the extension of a filename or URL 
		 * @param filename 	The string on which to search
		 * @return 			Everything trailing the final '.' character
		 * 
		 */
		public static function extension(filename:String):String {
			if (filename && filename.lastIndexOf(".") > 0) {
				if (filename.lastIndexOf("?") > 0){
					filename = String(filename.split("?")[0]); 
				}
				return filename.substring(filename.lastIndexOf(".")+1, filename.length).toLowerCase();
			} else {
				return "";
			}
		}
		
		/**
		 * Recursively creates a string representation of an object and its properties.
		 * 
		 * @param object The object to be converted to a string.
		 */
		public static function print_r(object:Object):String {
			var result:String = "";
			if (typeof(object) == "object") {
				result += "{";
			}
			for (var property:Object in object) {
				if (typeof(object[property]) == "object") {
					result += property + ": ";
				} else {
					result += property + ": " + object[property];
				}
				result += print_r(object[property]) +  ", ";
			}
			
			if (result != "{"){
				result = result.substr(0, result.length - 2);
			}
			
			if (typeof(object) == "object") {
				result += "}";
			}
			
			return result;
		}
		
		public static function convertQualifideClassNameToString(val:String):String {
			return val.replace(/^(\S*\:\:)?/,'');
			
		}
		
		/** Remove white space from before and after a string. **/
		public static function trim(s:String):String {
			return s.replace(/^\s+/, '').replace(/\s+$/, '');
		}
		
		/** Get the value of a case-insensitive attribute in an XML node **/
		public static function xmlAttribute(xml:XML, attribute:String):String {
			for each (var attrib:XML in xml.attributes()) {
				if (attrib.name().toString().toLowerCase() == attribute.toLowerCase())
					return attrib.toString();
			}
			return "";
		}


		/** Removes potentially harmful string headers from a link **/
		public static function cleanLink(link:String):String {
			return link.replace(/(javascript|asfunction|vbscript)\:/gi, "");
		}
		

		/**
		 * Decode JSON string.
		 *  
		 * @param str
		 * @return null if str is invalid JSON string
		 * 
		 */
		public static function json_decode(str:String):Object{
			
			try{
				return JSON.parse(str);
			}catch(evt:*) {
				return str;
			}
	
			return null;
		}
		
		
		
		/**
		 * Validate domain string and return true iff str represent valid domain name.
		 * <br/>
		 * <b>Accept domains:</b> http://ex.re/, https://ex.re, ex.re, ex.re/, sub.doma.in, ftp://so.me/
		 * <br/> 
		 * <b>Reject domains:</b> htp:/ru.ru, exampl.e, http://this.is/your/long/link
		 *  
		 * @param str
		 * @return Return domain name in form "sub_n.<any number of subdomains>.sub_1.domain.com" if domain is valid; otherwise <i>null</i>
		 * 
		 * @example 
		 */
		public static function validateDomain(str:String):String{
			var regex:RegExp = new RegExp("^(?:\\w+\\:\\/\\/)?([\\w\\d\\.\\_\\-]+\\.\\w\\w+)\\/?$");
			
			var arr:Array =  str.match(regex);
			
			if(arr)
				return arr[1];
			else
				return null;
		}
		
		
		/**
		 * Insert params to string (use for locale strings)
		 *  
		 * @param str String containing params placeholders of type <i>${i}</i> where <i>i</i> is int
		 * 
		 * @param params Array of params
		 * 
		 */
		public static function interpolate(str:String, params:Array):String{
			
			if(!params || params.length === 0)
				return str;
			
			for (var i:int = 0; i < params.length; i++)
			{
				str = str.replace(new RegExp("\\$\\{"+(i+1)+"\\}", "g"), params[i]);
			}
			
			return str;
		}
		
		
		public static function truncate(str:String, len:int):String{
			if (str.length <= len) {
				return str;
			}
			return str.slice(0, len) +"...";
		}
		
	}
	
}