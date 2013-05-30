package ru.teachbase.module.documents.layout
{
import mx.core.ILayoutElement;

import ru.teachbase.module.documents.renderers.SlideItemRenderer;

import spark.layouts.supportClasses.LayoutBase;

public class CustomVerticalLayout extends LayoutBase
	{
		private var _padding:Number = 0;
		
		public function CustomVerticalLayout(p:Number = 0)
		{
			super();
			_padding = p;
		}
		
		override public function updateDisplayList(width:Number, height:Number):void
		{
			super.updateDisplayList(width,height);
			if (useVirtualLayout) {
				updateVitrualDisplayList();
			}else{
				updateRealDisplayList(width,height);
			}
		}
		
		private function updateRealDisplayList(width:Number, height:Number):void{
			const targetWidth:Number = target.width;
			var topPosition:Number = _padding;
			var previosRatio:Number = 1;
			const count:int = target.numElements;
			if ( count == 0) {return;}

			var h:Number;	
			
			var el:ILayoutElement;
			for (var i:int = 0; i< count; i++) {
				el = target.getElementAt(i);
				var ratio:Number = (el as SlideItemRenderer).ratio;
				if (isNaN(ratio)) ratio = previosRatio; 
				previosRatio = ratio;
				
				h = width/ratio;
				if (h< height) {h = height;}
						
				el.setLayoutBoundsSize(width-_padding*2, h-(_padding*2));
				el.setLayoutBoundsPosition(_padding,topPosition);
				
				if (i==0 ) {typicalLayoutElement = el;}
				topPosition += h;
			}
			
			
			target.setContentSize((width+_padding*2), topPosition);
			if (count>2 ){
				verticalScrollPosition = target.getVirtualElementAt(0).height+_padding*2;
			}else if (count == 1) {
				verticalScrollPosition = 0;
			}
		}

		private function updateVitrualDisplayList():void{
			//Нам не нужен, так как и так обновляем dataProvider и больше 3 компонентов здесть не может быть
		}
		
		override protected function scrollPositionChanged():void
		{
			super.scrollPositionChanged();
		}

		public function getNextScrollSize():Number{
			return typicalLayoutElement.getLayoutBoundsHeight()+_padding*2;
		}
		
		public function getPreviousScrollSize():Number{
			return typicalLayoutElement.getLayoutBoundsHeight()+_padding*2;
		}
		
		override public function elementAdded(index:int):void
		{
			super.elementAdded(index);
		}
		
		
	}
	
}