package ru.teachbase.utils
{
public final class LayoutUtils
	{
		public function LayoutUtils()
		{
		}
		
		public static function accuratePercentMultiply(sum:int,percent:int):int{
			
			var a:int = sum * (percent / 100);
			var b:int = sum * (1 - (percent / 100));
		
			var defect:int = sum - a - b;
			
			if(defect===0)
				return a;
			else
				return (a+1);
			
		}
		
		
		
		
	}
}