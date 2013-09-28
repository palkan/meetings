package ru.teachbase.components.board.instruments
{
import flash.display.Graphics;
import flash.events.MouseEvent;
import flash.geom.Rectangle;

import ru.teachbase.components.board.model.FigurePoint;
import ru.teachbase.components.board.model.IFigure;
import ru.teachbase.components.board.style.FillStyle;
import ru.teachbase.components.board.style.StrokeStyle;

/**
	 * @author Aleksandr Kozlovskij (created: Apr 12, 2012)
	 */
	public class RectangleInstrument extends DrawInstrument
	{
		
		//------------ constructor ------------//
		
		private const strokeStyle:StrokeStyle = new StrokeStyle();
		private const fillStyle:FillStyle = new FillStyle();
		
		
		public function RectangleInstrument(tid:String = null)
		{
			super(tid || InstrumentType.RECTANGLE);
		}
		
		//------------ initialize ------------//
		
		internal static function initialize():void
		{
			registerClass(InstrumentType.RECTANGLE, RectangleInstrument);
		}
		
		//--------------- ctrl ---------------//
		
		override protected function draw(points:Vector.<FigurePoint>, figure:IFigure = null):void
		{
			figure = figure || this.figure;
			
			const g:Graphics = figure.graphics;
			const r:Rectangle = new Rectangle(points[0].x, points[0].y, points[1].x - points[0].x, points[1].y - points[0].y);
			
			g.clear();
			fillStyle.color = figure.stroke.color;
			applyStyles(g, strokeStyle, fillStyle);
			g.drawRect(r.x, r.y, r.width, r.height);
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
			figure.setPoint(new FigurePoint(figure.mouseX, figure.mouseY), 0);//0,0 - start
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