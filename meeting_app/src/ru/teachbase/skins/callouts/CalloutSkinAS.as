package ru.teachbase.skins.callouts
{
import spark.skins.mobile.CalloutSkin;

public class CalloutSkinAS extends CalloutSkin
	{
		public function CalloutSkinAS()
		{
			super();

			contentBackgroundInsetClass = null;

			dropShadowVisible = false;

			useBackgroundGradient = false; 
			
			contentCornerRadius = 0; 
			backgroundCornerRadius = 0;
			frameThickness = 0; 
			arrowWidth = 20; 
			arrowHeight = 10; 
		}
		
		override protected function createChildren():void
		{

			arrow = new CustomCalloutArrow();
			arrow.id = "arrow";
			arrow.styleName = this;
			super.createChildren();

			addChild(arrow);
		}
	}
}
