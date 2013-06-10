package ru.teachbase.layout
{

import mx.core.IVisualElement;

import spark.layouts.supportClasses.LayoutBase;

/**
	 *  Layout represents a  binary tree.
	 */
	public class VideoLayout extends LayoutBase
	{
		private var _useVirtualLayout:Boolean = true;
		private var _gap:int = 5;
		private var _ratio:Number = 0.75;
		private var history:Object = {height:0,width:0,numElements:0};
		//------------ constructor ------------//
		
		public function VideoLayout()
		{
			super();
		}
		
		//------------ initialize ------------//
		
		
		//--------------- ctrl ---------------//
		
		override public function updateDisplayList(w:Number, h:Number):void
		{
			super.updateDisplayList(w, h);
			if(w*(w - history.width)!=0 || h*(h - history.height)!=0 || target.numElements*(target.numElements - history.numElements)!=0) 
				updateList(w,h);//updateDisplayListManual(w,h);
			
			history.width = w;
			history.width = h;
			history.numElements = target.numElements;
			
		}
		
		
		public function updateList(w:Number,h:Number):void{
			var count:int = target.numElements;
			
			var _maxWidth:Number = w -_gap;
			var _maxHeight:Number = h - _gap;
			var newWidth:int =1;
			var newHeight:int =1;
			
			var row:int = 1;
			var col:int = count;
			
			while ((newWidth*newWidth *ratio)*count <_maxWidth*_maxHeight) {
				if ((newWidth+_gap) * col < _maxWidth && (newWidth*ratio+_gap)*row <_maxHeight) {
					newWidth++;
				}else if((newWidth*ratio+_gap)*row >= _maxHeight){
					break;
				}else if((newWidth+_gap)* col >= _maxWidth && col>1){ 
					if (row*col-count >1 && row<2) {
						col--;
					}else{
						var needRow:int = Math.ceil( (row -(row*col-count))/(col-1));	
						if (needRow * (newWidth+_gap)*ratio > _maxHeight - (newWidth+_gap)*ratio*row) {
							break;
						}else{
							col--;
							row = row + needRow;
						}
					}
				}else{
					break;
				}
				
			}
			
			while ((newWidth+_gap)*col>_maxWidth) newWidth--;
			while ((newWidth*ratio+_gap)*col>_maxWidth) newWidth--;
			
			newHeight = newWidth*ratio;
			
						
			var cur:int;
			var currentElement:IVisualElement;
			var _startX:Number= (w - newWidth*col - _gap*(col-1))/2;
			var _startY:Number = (h - newHeight*row - _gap*(row-1))/2;
			var posX:Number = _startX;
			var posY:Number = _startY;
			
			for(var i:int = 0; i<row;i++){
				for (var f:int = 0; f<col;f++) {
					if(cur >= count) break;
					
					if(this.useVirtualLayout)
						currentElement = target.getVirtualElementAt(cur);
					else
						currentElement = target.getElementAt(cur);
					
					currentElement.setLayoutBoundsPosition(posX,posY);
					currentElement.setLayoutBoundsSize(newWidth,newHeight);
					posX = posX + newWidth+_gap;	
					cur++;
				}
				posY = posY+newHeight+_gap;
				posX = _startX;
			}
		}
		
		
						
		//------------ get / set -------------//
		
		public function get gap():int
		{
			return _gap;
		}
		
		public function set gap(value:int):void
		{
			if(_gap === value && !target)
				return;
		
			_gap = value;
			updateDisplayList(history.width,history.height);
		}
		
		
		public function get ratio():Number
		{
			return _ratio;
		}
		
		public function set ratio(value:Number):void
		{
			if(_ratio === value && !target)
				return;
			
			_ratio = value;
			updateDisplayList(history.width,history.height);
		}
			
		
		//------- handlers / callbacks -------//
		
		}
	}
