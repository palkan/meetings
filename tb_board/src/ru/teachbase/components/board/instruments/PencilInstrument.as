package ru.teachbase.components.board.instruments
{
import flash.display.Graphics;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.utils.Dictionary;

import ru.teachbase.assets.wb.PencilCursor;

import ru.teachbase.components.board.model.*;
import ru.teachbase.utils.geom.SmoothCurve;

/**
	 * @author Aleksandr Kozlovskij (created: Mar 21, 2012)
	 */
	public class PencilInstrument extends DrawInstrument
	{
		/**
		 * [figure] = SmoothCurve
		 */		
		private var curves:Dictionary = new Dictionary(true);
		
		
		//------------ constructor ------------//
		
		public function PencilInstrument(type:String = null)
		{

			var _tid:String;

			_tid = (type) ? type : InstrumentType.PENCIL;

			super(_tid);

            _cursor = (new PencilCursor()).toDisplayObject();
		}
		
		//------------ initialize ------------//
		
		internal static function initialize():void
		{
			registerClass(InstrumentType.PENCIL, PencilInstrument);
		}
		
		//--------------- ctrl ---------------//
		
		override protected function draw(points:Vector.<FigurePoint>, figure:IFigure = null):void
		{
			
			figure = figure || this.figure;
			
			if(!points || !points.length)
				return;
			
			const curve:SmoothCurve = curves[figure];
			const g:Graphics = figure.graphics;
			g.clear();
			
			applyStyles(g, figure.stroke); //g.lineStyle(3, 0x0);
			
			if(curve)
			{
				curve.draw(g);
				return;
			}
			
			
			g.moveTo(points[0].x, points[0].y);
			
			for(var i:int = 0; i < points.length; ++i)
				g.lineTo(points[i].x, points[i].y);
			
		}
		
		override protected function completeFigure(figure:IFigure = null):void
		{
			figure = figure || this.figure;
			
			// optimize:
			const points:Vector.<FigurePoint> = figure.points;
			
			// clean:
			var i:int = 0;
			var p:Point;
			var prev:Point;
			var len:Number = calcAverageLength(points);
			for(; i < points.length; ++i)
			{
				p = points[i];
				if(prev && p && Math.abs(Point.distance(prev, p)) < len)
					points.splice(i--, 1);
				prev = p;
			}
			
			// smooth:
			if(points && points.length > 3 && !curve)
				curves[figure] = new SmoothCurve();
			
			if(points && points.length > 3)
			{
				const curve:SmoothCurve = curves[figure];
				curve.start = points[0];
				curve.end = points[points.length - 1];
				
				for(i = 1; i < points.length - 1; ++i)
					curve.pushControl(points[i]);
			}
			
			// super:
			super.completeFigure(figure);
			
			curve && draw(points, figure);
		}
		
		private function calcAverageLength(points:Vector.<FigurePoint>):Number
		{
			if(!points || points.length < 2)
				return 0;
			
			const results:Array = new Array();
			
			var p:Point;
			var prev:Point;
			for(var i:int; i < points.length; ++i)
			{
				p = points[i];
				if(prev && p)
					results.push(Math.abs(Point.distance(prev, p)));
				prev = p;
			}
			
			results.sort(Array.NUMERIC);
			
			var average:Number = results[0];
			
			if(results.length < 2)
				return average;
			
			/*for(i = 1; i < results.length; ++i)
				average += results[i];
			average /= results.length;*/
			return results[Math.round(results.length / 4)];
			
			return average;
		}
		
		
		//------------ get / set -------------//
		
		
		
		
		
		//------- handlers / callbacks -------//
		
		
		
		
		override protected function mouseDownHanlder(e:MouseEvent):void
		{
		
			super.mouseDownHanlder(e);
			
			if(!figure) return;
			
			figure.numPoints = 0;
			figure.setPoint(new FigurePoint(figure.mouseX, figure.mouseY), 0);
		}
		
		override protected function mouseMoveHanlder(e:MouseEvent):void
		{
			figure.addPoint(new FigurePoint(mouseX - startGlobal.x, mouseY - startGlobal.y));
			figure.pointsUpdated(figure.numPoints - 1);
		}
	}
}