package ru.teachbase.module.documents.components
{
import spark.components.Button;
import spark.components.HSlider;

public class CustomHSlider extends HSlider
	{
		
		[SkinPart(required="true")]
		public var bufferTrack:Button;
		
		[SkinPart(required="true")]
		public var progressTrack:Button;
		
		private var _buffered:Number = 0;
		private var _value:Number = 0;
		
		public function CustomHSlider()
		{
			super();
		}
		
		public function set buffered(val:Number):void{
			if (val >=1){
				if (_buffered <1)
					val = 1;
				else
					return;
			}
			_buffered = val;
			redraw();
		}
				
		override protected function setValue(val:Number):void {
			super.setValue(val);
			_value = val;
			redraw();
		}
	
		public function redraw():void{
			if (bufferTrack) 
				bufferTrack.width = this.width*_buffered;
			if (progressTrack)
				progressTrack.width = this.width*_value/this.maximum;
		}
		
		override public function setActualSize(w:Number, h:Number):void
		{
			super.setActualSize(w, h);
			redraw();
		}
		
		
	}
}