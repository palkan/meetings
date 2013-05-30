package ru.teachbase.module.documents.layout
{
import mx.core.ILayoutElement;

import ru.teachbase.module.documents.renderers.SlideItemRenderer;

import spark.layouts.supportClasses.LayoutBase;

public class CustomHorizontalLayout extends LayoutBase
	{
		private var _padding:Number = 0;
		
		public function CustomHorizontalLayout(p:Number = 0)
		{
			super();
			_padding = p;
		}
		
		override public function updateDisplayList(width:Number, height:Number):void
		{
			super.updateDisplayList(width,height);
			if (useVirtualLayout) {
				updateVitrualDisplayList(width,height);
			}else{
				updateRealDisplayList(width,height);
			}
		}
		
		private function updateRealDisplayList(width:Number,height:Number):void{
			const targetWidth:Number = target.width;
			var leftPosition:Number = _padding;
			
			const count:int = target.numElements;
			if ( count == 0) return;
						
			var el:ILayoutElement;
			
			for (var i:int = 0; i< count; i++) {
				
				el = target.getVirtualElementAt(i);
				const ratio:Number = (el as SlideItemRenderer).ratio;
				
				el.setLayoutBoundsPosition(leftPosition,_padding);
				el.setLayoutBoundsSize(width-_padding*2, height-_padding*2);
				leftPosition += width;
			}
			if (count>2 ){
				horizontalScrollPosition = width;
			}
			target.setContentSize(count*width, height);
		}
		
		private function updateVitrualDisplayList(width:Number,height:Number):void{
			//Нам не нужен, так как и так обновляем dataProvider и больше 3 компонентов здесть не может быть
		}
		
		override protected function scrollPositionChanged():void
		{
			super.scrollPositionChanged();
		}
	}
	
}