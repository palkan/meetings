package ru.teachbase.skins
{
import spark.skins.mobile.supportClasses.CalloutArrow;

public class CustomCalloutArrow extends CalloutArrow
	{
		public function CustomCalloutArrow()
		{
			super();
			
			borderThickness = NaN; 
			gap = 0;
			useBackgroundGradient = false;
			
		}
	}
}