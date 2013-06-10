package ru.teachbase.behaviours
{
import flash.display.Sprite;
import flash.events.MouseEvent;

import ru.teachbase.behaviours.interfaces.IDraggle;
import ru.teachbase.behaviours.interfaces.IDraggleSnapshot;
import ru.teachbase.behaviours.interfaces.IDropContainer;
import ru.teachbase.behaviours.interfaces.IDropCoordinateSpace;

/**
	 * @author Teachbase (created: Jan 24, 2012)
	 */
	public final class DragDropBehavior extends DragBehavior
	{
		
		//--- properties:
		public var container:IDropContainer;
		
		//--- state:
		
		private var snapshot_catch:IDraggleSnapshot;
		
		//------------ constructor ------------//
		
		public function DragDropBehavior()
		{
			super();
		}
		
		//------------ initialize ------------//
		
		//--------------- ctrl ---------------//
		
		override protected function startDrag():void
		{
			if(dragging)
				return;
			
			if(snapshot)
				snapshot.move(lastMouse.x,lastMouse.y);
			
			super.startDrag();
			
			dragging && container && container.addSnapshot(snapshot, startMouse);
		}
		
		private function continueDrag():void
		{
			if(!dragging)
				return;
			
			if(container)
			{
				const drop:IDropCoordinateSpace = container.getDropUnderPoint(lastMouse);
				
				// prepareDrop 
				if(drop && drop !== _target/* && drop.isPossibleDropFor(_target as IDraggle)*/)
					drop.prepareDrop(snapshot, lastMouse);
			}
		}
		
		override protected function stopDrag():void
		{
			if(!dragging)
				return super.stopDrag();
			
			if(container)
			{
				const drop:IDropCoordinateSpace = container.getDropUnderPoint(lastMouse);
				
				
				// isPossibleDropFor 
				if(!drop || drop === _target || !drop.isPossibleDropFor(_target as IDraggle))
				{
					disposeTempListeners();
					returnToStartPosition();
					super.stopDrag();
					drop.cancelDrop(snapshot);
					return;
				}
				else
					drop.drop(snapshot, lastMouse);
				
				container.removeSnapshot(snapshot);
			}
			
			super.stopDrag();
			
			snapshot_catch = null;
		}
		
		override protected function returnToStartPosition():void
		{
			super.returnToStartPosition();
			
			container.removeSnapshot(snapshot);
		}
		
		private function requestSnapshot():void
		{
			_target is IDraggle && (snapshot_catch = (_target as IDraggle).getSnapshot());
		}
		
		//------------ get / set -------------//
		
		override public function get draggle():Sprite
		{
			return dragging ? snapshot as Sprite || super.draggle : super.draggle;
		}
		
		private function get snapshot():IDraggleSnapshot
		{
			return snapshot_catch || (_target is IDraggle && container ? (requestSnapshot(), snapshot_catch) : super.draggle as IDraggleSnapshot);
		}
		
		//------- handlers / callbacks -------//
		
		override protected function moveHandler(e:MouseEvent):void
		{
			super.moveHandler(e);
			
			dragging && continueDrag();
		}
	}
}