package ru.teachbase.skins
{
import flash.filters.DropShadowFilter;

import mx.skins.ProgrammaticSkin;

public class CustomToolTipSkin extends ProgrammaticSkin {
		
		public function CustomToolTipSkin():void{
			super();
		}
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void{
			graphics.clear();
			graphics.lineStyle(1, 0x28689A, 1);
			graphics.beginFill(0xFFFFFF, 1);
			graphics.drawRect(0, 0, unscaledWidth, unscaledHeight);
			graphics.endFill();
			filters = [new DropShadowFilter(2,45,0x00000,4,4)];
		}
	}
}