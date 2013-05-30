package ru.teachbase.module.board.components
{

import ru.teachbase.utils.shortcuts.style;

import spark.layouts.supportClasses.LayoutBase;

public class WBListLayout extends LayoutBase
	{
		
		public static const HORIZONTAL:String = "h";
		public static const VERTICAL:String = "v";
		
		
		private var _useActive:Boolean = true;
		
		private var _gap:uint = 0;
		
		private var lastWidth:Number = 0;
		private var lastHeight:Number = 0;
		
		private var _orientation:String = "h";
		
		
		private var skin:Object = new Object();
		
		public function WBListLayout()
		{
			super();
			
			
			
		}
		
		override public function updateDisplayList(width:Number, height:Number):void{
			super.updateDisplayList(width,height);
			lastWidth = width;
			lastHeight = height;
			
			if(!target)
				return;
			
			
			if(this.orientation === WBListLayout.HORIZONTAL)
				updateDisplayListHor();
			else
				updateDisplayListVert();
			
			
		}
		
		
		private function updateDisplayListHor():void{
			
			const length:int = target.numElements;
			
			var _x:int = 0;
			
			//var _w:int = target.width / length;
			//var _h:int = target.height;
			
			var _last:WBButton;
			var _first:WBButton;
			
			for(var i:int = 0; i<length;i++){
				
				var el:IWBComponent;
				
				if(this.useVirtualLayout)
					el = target.getVirtualElementAt(i) as IWBComponent;
				else
					el = target.getElementAt(i) as IWBComponent;
				
				if(el.active || !this.useActive){
					
					if(!_first)
						_first = el as WBButton;
					
					el.setLayoutBoundsPosition(_x,0);
					//el.setLayoutBoundsSize(_w,_h);
					el.visible = true;
					_x+= el.width+_gap;
					//target.setLayoutBoundsSize(_x,el.height);
					target.width = _x;
					
					(el as WBButton).iconUp = skin.normal.up;
					(el as WBButton).iconDown = skin.normal.over;
					(el as WBButton).iconOver = skin.normal.over;
					
					
					_last = (el as WBButton);		
					
				}else{
					
					el.visible = false;
					
				}
				
				
				

			}
			
			if(_last != _first){
				
				_last.iconUp = skin.right.up;
				_last.iconOver = skin.right.over;
				_last.iconDown = skin.right.over;
				
			}
			
			
			
		}
		
		
		private function updateDisplayListVert():void{
			
			const length:int = target.numElements;
			
			var _y:int = 0;
			
			
			
			//var _w:int = target.width;
			//var _h:int = target.height / length;
			
			var _last:WBButton;
			
			
			for(var i:int = 0; i<length;i++){
				
				var el:IWBComponent;
				
				if(this.useVirtualLayout)
					el = target.getVirtualElementAt(i) as IWBComponent;
				else
					el = target.getElementAt(i) as IWBComponent;
				
				if(el.includeInLayout){
				
				
				if(el.active || !this.useActive){
					
					el.setLayoutBoundsPosition(0,_y);
				//	el.setLayoutBoundsSize(_w,_h);
					el.visible = true;
					_y+= el.height+_gap;
					target.height = _y;
					//target.setLayoutBoundsSize(el.width,_y);
					
					if(el is WBButton){
					
						if(i>0){
							(el as WBButton).iconUp = skin.normal.up;
							(el as WBButton).iconOver = skin.normal.over;
							(el as WBButton).iconDown = skin.normal.disabled;
							(el as WBButton).iconDisabled = skin.normal.disabled;
						}
					
					
						_last = (el as WBButton);
					}
					
				}else{
					
					el.visible = false;
					
				}
				
				}
				
			}
			
			_last.iconUp = skin.bottom.up;
			_last.iconOver = skin.bottom.over;
			_last.iconDown = skin.bottom.disabled;
			_last.iconDisabled = skin.bottom.disabled;


			
		}
		
		

		public function get useActive():Boolean
		{
			return _useActive;
		}

		public function set useActive(value:Boolean):void
		{
			_useActive = value;
			updateDisplayList(lastWidth,lastHeight);
		}

		public function get orientation():String
		{
			return _orientation;
		}

		public function set orientation(value:String):void
		{
			_orientation = value;
			
			if(_orientation == VERTICAL){
				
				skin.normal = {};
				skin.normal.up = style("wb","buttonUp");
				skin.normal.over = style("wb","buttonOver");
				skin.normal.disabled = style("wb","buttonDisabled");
				
				skin.bottom = {};
				skin.bottom.up = style("wb","buttonBotUp");
				skin.bottom.over = style("wb","buttonBotOver");
				skin.bottom.disabled = style("wb","buttonBotDisabled");
				
			}else{			
				
				skin.normal = {};
				skin.normal.up = style("wb","buttonListUp");
				skin.normal.over = style("wb","buttonListOver");
				
				skin.right = {};
				skin.right.up = style("wb","buttonListRightUp");
				skin.right.over = style("wb","buttonListRightOver");
				
			}
			
		}

		public function get gap():uint
		{
			return _gap;
		}

		public function set gap(value:uint):void
		{
			_gap = value;
			
			updateDisplayList(lastWidth,lastHeight);
		}
		
		
		
	}
}