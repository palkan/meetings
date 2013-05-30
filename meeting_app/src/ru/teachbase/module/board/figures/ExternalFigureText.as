package ru.teachbase.module.board.figures
{
import ru.teachbase.module.board._figures;
import ru.teachbase.module.board.instruments.TextInstrument;

public class ExternalFigureText extends ExternalFigure
	{
		public function ExternalFigureText(manager:FigureManager, figure:IFigure, id:String=null)
		{
			super(manager, figure, id);
		}
		
		override public function sendUpdate(param:String, value:*, instrument:String):void
		{
			if(ignorLocalChanges) return;
			
			var _x:Number = (figure as Figure).x * (TextInstrument.FIXED_WIDTH / manager.container.formatBounds.width);
			var _y:Number = (figure as Figure).y * (TextInstrument.FIXED_WIDTH / manager.container.formatBounds.width);
			
			manager.figureChanged(this, {id:id, text:(figure as Figure).textField.text, page:(figure as Figure).page_id, type:"update", color:(figure as Figure).color, x:_x, y:_y, scale:figure.scaleDelta, initialCanvasWidth:figure.initialCanvasWidth, instrument:instrument});
		
		} 
		
		
		override public function updateProperties(changes:Object):void
		{
			(figure as Figure)._figures::setInitialCanvasWidth(changes.initialCanvasWidth);
			
			if(changes.text){
				
				(figure as Figure).textField.text = changes.text;
				
			}
		}
	}
}