package ru.teachbase.layout
{

import spark.layouts.supportClasses.LayoutBase;

public class TreeLayout extends LayoutBase
	{
		
		private var _controller:LayoutController;
		
		/** Last width */
		private var _w:int=-1;
		/** Last height */
		private var _h:int=-1;
		
		
		public function TreeLayout()
		{
			super();
		}
		
		
		override public function updateDisplayList(w:Number, h:Number):void{
			
			
			if(_controller && _controller.initialized){
				super.updateDisplayList(w, h);
				_controller.updateDisplayList();
				_w = w;
				_h = h;
			}
			
			
			
		}

		public function set controller(value:LayoutController):void
		{
			_controller = value;
		}

	}
}