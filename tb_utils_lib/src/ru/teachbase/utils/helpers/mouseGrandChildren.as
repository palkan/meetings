package ru.teachbase.utils.helpers
{
import flash.display.DisplayObjectContainer;

public function mouseGrandChildren(container:DisplayObjectContainer,enable:Boolean):void
	{
			
			for(var i:int = 0; i < container.numChildren; i++){
				
				if(container.getChildAt(i) is DisplayObjectContainer)
					(container.getChildAt(i) as DisplayObjectContainer).mouseChildren = enable;
				
		}
	}
}