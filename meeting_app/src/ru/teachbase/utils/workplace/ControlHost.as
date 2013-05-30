package ru.teachbase.utils.workplace
{
	public class ControlHost
	{
		
		public static const RENDERER:uint = 1;
		public static const CONTAINER:uint = 1 << 1;
		public static const BOTH:uint = RENDERER + CONTAINER;
		
		
		public static function isRenderer(value:uint):Boolean{
			
			return Boolean(value & RENDERER);
			
		}
		
		public static function isContainer(value:uint):Boolean{
			
			return Boolean(value & CONTAINER);
			
		}
		
		public static function isBoth(value:uint):Boolean {
			return Boolean(value & BOTH);
		}

	}
}