package ru.teachbase.module.board.figures
{
import flash.geom.Point;
import flash.utils.getQualifiedClassName;

import ru.teachbase.module.board._figures;
import ru.teachbase.utils.helpers.isList;
import ru.teachbase.utils.helpers.toArray;

/**
	 * @author Aleksandr Kozlovskij (created: Apr 2, 2012)
	 */
	public class ExternalFigure
	{
		private static const ID_PREFIX:String = 'fig:';
		private var _id:String;
		private var _figure:IFigure;
		protected var manager:FigureManager;
		
		public var ignorLocalChanges:Boolean = false;
		
		//------------ constructor ------------//
		
		public function ExternalFigure(manager:FigureManager, figure:IFigure, id:String = null)
		{
			this._figure = figure;
			figure.external = this;
			
			this.manager = manager;
			
			// id = external / self-generated
			_id = id || (ID_PREFIX + new Date().time);
		}
		
		//------------ initialize ------------//
		
		//--------------- ctrl ---------------//
		
		public function sendUpdate(param:String, value:*, instrument:String):void
		{
			if(ignorLocalChanges) return;
			
			manager.figureChanged(this, {id:id, page:(figure as Figure).page_id, type:"update", stroke:(figure as Figure).thickness, color:(figure as Figure).color, fill:(figure as Figure).fillColor, x:(figure as Figure).x, y:(figure as Figure).y, scale:figure.scaleDelta, initialCanvasWidth:figure.initialCanvasWidth, ('' + param) : simpliciter(value), instrument:instrument});
		}
		
		public function pointsUpdated(firstPointIndex:int = 0, length:int = int.MAX_VALUE):void
		{
			_figure.pointsUpdated(firstPointIndex, length);
		}
		
		public function updateProperties(changes:Object):void
		{
			(figure as Figure)._figures::setInitialCanvasWidth(changes.initialCanvasWidth);
			
			for(var key:* in changes.points)
			{
				figure.setPoint(new FigurePoint(changes.points[key].x, changes.points[key].y), int(key));
			}
			
			
			pointsUpdated();
		}
		
		private static const VECTOR_NAME:String = getQualifiedClassName(Vector);
		private function simpliciter(data:*):*
		{
			
			// type using for debug
			const type:String = getQualifiedClassName(data);
			
			if(data is Object)
			{
				if(data is Point)
					data = {x:data.x, y:data.y, type:type};
					
				else
				if(data is Function)
					return data = null;
				
				else
				// simplify self:
				if(isList(data))
				{
					data = toArray(data) || data;
					
					// simplify content:
					//for each(var key:* in data)
					for(var key:* in data)
					{
						if(key == null) continue;
						data[key] = simpliciter(data[key]);
						if(data[key] == null || data[key] == undefined)
							delete data[key];
					}
				}
			}
			
			return data;
		}
		
		//------------ get / set -------------//
		
		public function get id():String
		{
			return _id;
		}
		
		public function get figure():IFigure
		{
			return _figure;
		}
		
		//------- handlers / callbacks -------//
		
	}
	
	
	
	
	
}