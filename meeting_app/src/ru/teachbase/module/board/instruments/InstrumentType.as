package ru.teachbase.module.board.instruments
{
	
	/**
	 * @author Aleksandr Kozlovskij (created: Mar 19, 2012)
	 */
	public final class InstrumentType
	{
		public static const POINTER:String = 'pointer';
		
		public static const ERASER:String = 'eraser';
		
		public static const PENCIL:String = 'pencil';
		public static const LINE:String = 'line';
		public static const CURVE:String = 'curve';
		public static const ARROW:String = 'arrow';
		public static const MARKER:String = 'marker';
		
		public static const RECTANGLE:String = 'rectangle';
		public static const CIRCLE:String = 'circle';
		public static const TEXT:String = 'text';
		
		/*public static const ALL:Array = [
										 POINTER,
										 
										 ERASER,
										 
										 PENCIL,
										 LINE,
										 CURVE,
										 ARROW,
										 
										 RECTANGLE,
										 CIRCLE,
										 TEXT,
										 //...
										];*/
		public static const ALL:Array = [ PENCIL, LINE, CIRCLE, RECTANGLE ]; 
	}
}