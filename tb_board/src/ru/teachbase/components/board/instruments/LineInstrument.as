package ru.teachbase.components.board.instruments
{
import flash.display.Graphics;
import flash.events.MouseEvent;

import ru.teachbase.components.board.model.FigurePoint;
import ru.teachbase.components.board.model.IFigure;

/**
	 * @author Aleksandr Kozlovskij (created: Mar 19, 2012)
	 */
	public class LineInstrument extends DrawInstrument
	{
		
		//------------ constructor ------------//
		
		public function LineInstrument()
		{
			super(InstrumentType.LINE);
		}
		
		//------------ initialize ------------//
		
		internal static function initialize():void
		{
			registerClass(InstrumentType.LINE, LineInstrument);
		}
		
		//--------------- ctrl ---------------//
		
		override protected function draw(points:Vector.<FigurePoint>, figure:IFigure = null):void
		{
			figure = figure || this.figure;
			
			const g:Graphics = figure.graphics;
			
			// temp test:
			g.clear();
			applyStyles(g, figure.stroke); //g.lineStyle(3, 0x0);
			g.moveTo(points[0].x, points[0].y);
			g.lineTo(points[1].x, points[1].y);
		}
		
		//------------ get / set -------------//
		
		//------- handlers / callbacks -------//
		
		override protected function mouseDownHanlder(e:MouseEvent):void
		{
			if(!isValidDown(e))
				return;
			
			super.mouseDownHanlder(e);
			
			if(!figure) return;
			
			figure.numPoints = 2;
			figure.setPoint(new FigurePoint(figure.mouseX, figure.mouseY), 0);
			figure.setPoint(new FigurePoint(0, 0), 1);
		}
		
		override protected function mouseMoveHanlder(e:MouseEvent):void
		{
			const end:FigurePoint = figure.getPoint(1);
			end.x = mouseX - startGlobal.x;
			end.y = mouseY - startGlobal.y;
			figure.pointsUpdated(1);
		}
	}
}