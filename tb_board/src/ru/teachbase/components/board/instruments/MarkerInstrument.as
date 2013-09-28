package ru.teachbase.components.board.instruments
{
import flash.display.Graphics;

import ru.teachbase.assets.wb.MarkerCursor;

import ru.teachbase.components.board.style.FillStyle;
import ru.teachbase.components.board.style.StrokeStyle;

public class MarkerInstrument extends PencilInstrument
	{
		
		public static const THICKNESSX:int = 5;
		
		public function MarkerInstrument()
		{
			super(InstrumentType.MARKER);

            _cursor = (new MarkerCursor()).toDisplayObject();
			
		}
		
		//------------ initialize ------------//
		
		internal static function initialize():void
		{
			registerClass(InstrumentType.MARKER, MarkerInstrument);
		}
		
		override public function applyStyles(graphics:Graphics, stroke:StrokeStyle, fill:FillStyle=null):void{
			
			graphics.lineStyle(stroke.thickness * THICKNESSX, stroke.color, 0.3);
		}
	}
}