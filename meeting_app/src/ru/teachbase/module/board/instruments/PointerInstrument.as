package ru.teachbase.module.board.instruments
{
import ru.teachbase.module.board.figures.FigureManager;

/**
	 * @author Vova Dem (created: Sep 17, 2012)
	 */
	public class PointerInstrument extends Instrument
	{
				
		//------------ constructor ------------//
		
		public function PointerInstrument()
		{
			super(InstrumentType.POINTER);
		}
		
		//------------ initialize ------------//
		
		internal static function initialize():void
		{
			registerClass(InstrumentType.POINTER, PointerInstrument);
		}
		
		override public function initialize(manager:FigureManager):void
		{
			super.initialize(manager);
			
			if(super.manager && target)
			{
				manager.createSharedCursor();
			}
		}
		
		override public function dispose():void
		{
			if(super.manager){
				manager.removeSharedCursor();
			}
			super.dispose();
		}
		
		//--------------- ctrl ---------------//
		
		
		//------------ get / set -------------//
		
		
		
	}
}