package ru.teachbase.utils.chain
{
/**
	 * @author Teachbase (created: May 18, 2012)
	 */
	public final class ChainMode
	{

		/**
		 * No data is sent, just collect all data in Array 
		 */
		public static const SAVING:uint =              1 << 0;
		
		/**
		 * Only last data is sent; storage contains only one element 
		 */
		public static const ONLY_LAST:uint =           1 << 1;
		
		/**
		 * First, last and middle data are sent simultaneously (middle is <code>_storage[Math.floor(_storage.length/2)]</code> 
		 */
		public static const FIRST_MIDDLE_LAST:uint =   1 << 2;
		
		/**
		 * All data is sent  simultaneously
		 */
		public static const ALL:uint =                 1 << 4;
		
		/**
		 * One merged data is sent; need to specify merge function in chain
		 */
		public static const MERGE_TO_NEXT:uint =	   1 << 5;
		
		
	}
}