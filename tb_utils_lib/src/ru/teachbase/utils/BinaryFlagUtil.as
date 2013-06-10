package ru.teachbase.utils
{
	
	/**
	 * @author Teachbase (created: May 4, 2012)
	 */
	public class BinaryFlagUtil
	{
		public static const MASK_31:uint = 1 << 31;
		public static const MASK_24:uint = 0x800000;
		
		public static function encode(value:uint, mask:uint):uint
		{
			return mask | value;
		}
		
		public static function decodeValue(value:uint, mask:uint, shift:uint = 0):uint
		{
			return (value & mask) >> shift;
		}
		
		public static function rewriteValue(original:uint, mask:uint, value:uint):uint
		{
			if(original & mask)
				original ^= original,
					original |= mask,
					original ^= original;
			original |= value;
			
			return original;
		}
		
		public static function rewriteBoolean(original:uint, mask:uint, value:Boolean):uint
		{
			return rewriteValue(original, mask, int(value));
		}
		
		// flag == mask //
		public static function flipFlag(original:uint, flag:uint):uint
		{
			//       flip   by mask
			return original ^= flag;
		}
	}
}