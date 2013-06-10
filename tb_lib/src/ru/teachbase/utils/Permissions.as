package ru.teachbase.utils
{
	public class Permissions
	{
		
		public static const ADMIN:uint = 1 << 3;
		public static const CAMERA:uint = 1 << 2;
		public static const MIC:uint = 1 << 1;
		public static const DOCS:uint = 1;
		
		public function Permissions()
		{
		}
		
		public static function isAdmin(value:uint):Boolean{
			
			return Boolean(value & ADMIN);
			
		}
		
		public static function camAvailable(value:uint):Boolean{
			
			return Boolean(value & CAMERA)|| isAdmin(value);
		}
		
		public static function micAvailable(value:uint):Boolean{
			
			return Boolean(value & MIC) || isAdmin(value);
		}
		
		public static function docsAvailable(value:uint):Boolean{
			
			return Boolean(value & DOCS) || isAdmin(value);
		}
		
		
		/**
		 * 
		 * @param right mask of the right to check
		 * @param permissions total user premissions
		 * @return <i>true</i> if user already has these rights
		 * 
		 */		
		
		public static function hasRight(right:uint, permissions:uint):Boolean{
			
			return Boolean(permissions & right);
		}
	}
}