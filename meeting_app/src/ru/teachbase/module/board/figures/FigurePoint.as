package ru.teachbase.module.board.figures
{
import flash.geom.Point;
import flash.net.registerClassAlias;
import flash.utils.getQualifiedClassName;

/**
	 * @author Aleksandr Kozlovskij (created: Mar 21, 2012)
	 */
	public final class FigurePoint extends Point
	{
		private static var initialized:Boolean;
		
		internal var index:uint;
		
		//------------ constructor ------------//
		
		public function FigurePoint(x:int = 0, y:int = 0, index:uint = 0)
		{
			initialized || FigurePoint.initialize();
			
			super(x, y);
			this.index = index;
		}
		
		//------------ initialize ------------//
		
		private static function initialize():void
		{
			initialized = true;
			registerClassAlias(getQualifiedClassName(FigurePoint).replace('::', '.'), FigurePoint);
		}
		
		//--------------- ctrl ---------------//
		
		//------------ get / set -------------//
		
		//------- handlers / callbacks -------//
		
	}
}