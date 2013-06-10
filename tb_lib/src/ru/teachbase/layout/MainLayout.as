package ru.teachbase.layout
{

import ru.teachbase.manage.LayoutControllerBase;

import spark.layouts.supportClasses.LayoutBase;

public class MainLayout extends LayoutBase
	{
		
		private var _controller:LayoutControllerBase;
		
		/** Last width */
		private var _w:int=-1;
		/** Last height */
		private var _h:int=-1;
		
		
		public function MainLayout()
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

		public function set controller(value:LayoutControllerBase):void
		{
			_controller = value;
		}

	}
}