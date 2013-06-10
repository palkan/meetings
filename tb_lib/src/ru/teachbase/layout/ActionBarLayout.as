package ru.teachbase.layout
{
import flash.display.DisplayObject;
import flash.events.Event;
import flash.geom.Point;
import flash.geom.Rectangle;

import mx.core.IVisualElement;
import mx.core.IVisualElementContainer;
import mx.events.ResizeEvent;
import mx.events.StateChangeEvent;

import ru.teachbase.behaviours.DragState;

import spark.components.supportClasses.GroupBase;
import spark.layouts.HorizontalLayout;

/**
	 * Layout states:
	 * <br/>
	 * static (normal) :
	 * <br/>
	 * | item | item | item | item |
	 * <br/>
	 * <br/>
	 * prepare [1]:
	 * <br/>
	 * | item |      | item | item |
	 * <br/>
	 * <br/>
	 * drag to [2 - 3]:
	 * <br/>
	 * | item |  <-| item | <--> | item |
	 * 
	 * @author Teachbase (created: Feb 1, 2012)
	 */
	public final class ActionBarLayout extends HorizontalLayout
	{
		private var waitTweenEnding:Boolean;
		
		private var currentDraggle:IVisualElement;
		private var currentDraggleStartIndex:int;
		private var currentDraggleX:int;
		
		//------------ constructor ------------//

		private var posibleDropIndex:int;

		
		public function ActionBarLayout()
		{
			super();
			useVirtualLayout = true;
		}
		
		//------------ initialize ------------//
		
		override public function elementAdded(index:int):void
		{
			if(currentDraggle === target.getElementAt(index))
				return;
			
			super.elementAdded(index);
			listenElement(target.getElementAt(index));
		}
		
		override public function elementRemoved(index:int):void
		{
			if(currentDraggle === target.getElementAt(index))
				return;
			
			super.elementRemoved(index);
			unlistenElement(target.getElementAt(index));
		}
		
		//--------------- ctrl ---------------//
		
		private function listenElement(element:IVisualElement):void
		{
			element.addEventListener(StateChangeEvent.CURRENT_STATE_CHANGE, elementStateChangedHandler, false, 0, true);
			element.addEventListener(ResizeEvent.RESIZE, elementResizeHandler, false, 0, true);
		}
		
		private function unlistenElement(element:IVisualElement):void
		{
			element.removeEventListener(StateChangeEvent.CURRENT_STATE_CHANGE, elementStateChangedHandler);
			element.removeEventListener(ResizeEvent.RESIZE, elementResizeHandler);
			
			unlistenElementPosition(element);
		}
		
		private function listenElementPosition(element:IVisualElement):void
		{
			if(!element)
				return;
			// xChanged not work with native drag engine
			//item.addEventListener("xChanged", itemMoveHandler, false, 0, true);
			//item.addEventListener("yChanged", itemMoveHandler, false, 0, true);
			
			element.addEventListener(Event.ENTER_FRAME, elementMoveHandler, false, 0, true);
		}
		
		private function unlistenElementPosition(element:IVisualElement):void
		{
			if(!element)
				return;
			element.removeEventListener(Event.ENTER_FRAME, elementMoveHandler);
		}
		
		//---
		
		override public function measure():void
		{
			super.measure();
		}
		
		override public function getElementBounds(index:int):Rectangle
		{
			return super.getElementBounds(index);
		}
		
		//-------------- utils ---------------//
		
		/**
		 *  Work-around the Player globalToLocal and scrollRect changing before
		 *  a frame is updated. 
		 */
		private function globalToLocal(x:Number, y:Number):Point
		{
			var layoutTarget:GroupBase = target;
			var parent:DisplayObject = layoutTarget.parent;
			var local:Point = parent.globalToLocal(new Point(x, y));
			local.x -= layoutTarget.x;
			local.y -= layoutTarget.y;
			
			var scrollRect:Rectangle = getScrollRect();
			if (scrollRect)
			{
				local.x += scrollRect.x;
				local.y += scrollRect.y;
			}
			return local;
		}
		
		//------------ get / set -------------//
		
		//------- handlers / callbacks -------//
		
		private function elementStateChangedHandler(e:StateChangeEvent):void
		{
			switch(e.newState)
			{
				case DragState.STATIC:
				{
					// INIT or DROP or RETURN (cancel)
					if(!e.oldState)
						return;
					
					unlistenElementPosition(e.currentTarget as IVisualElement)
					currentDraggle === e.currentTarget && (currentDraggle = null);
					
					if(posibleDropIndex !== -1)
					{
						currentDraggleStartIndex === posibleDropIndex; // ?
						
						moveElementInDisplayListTo(e.currentTarget as IVisualElement, posibleDropIndex);
					}
					
					target.autoLayout = true;
					break;
				}
					
				case DragState.PREPARING:
				{
					target.autoLayout = false;
					
					(currentDraggle = e.currentTarget as IVisualElement);
					currentDraggleStartIndex = target.getElementIndex(e.currentTarget as IVisualElement);
					break;
				}
					
				case DragState.DRAGGING:
				{
					moveElementInDisplayListToTop(e.currentTarget as IVisualElement);
					
					// listen for CHECK EVERY POSITION CHANGE
					listenElementPosition(e.currentTarget as IVisualElement);
					break;
				}
			}
			
			//lastStates[e.currentTarget] = e.ne
		}
		
		private function moveElementInDisplayListTo(element:IVisualElement, newInex:int):void
		{
			const target:IVisualElementContainer = target as IVisualElementContainer;
			newInex >= target.numElements ? moveElementInDisplayListToTop(element) : target.setElementIndex(element, newInex);
		}
		
		private function moveElementInDisplayListToTop(element:IVisualElement):void
		{
			const target:IVisualElementContainer = target as IVisualElementContainer;
			target.setElementIndex(element, target.numElements - 1);
		}
		
		
		
		private function elementMoveHandler(e:Event):void
		{
			const element:IVisualElement = e.currentTarget as IVisualElement;
			
			if(currentDraggleX === element.x)
				return;
			
			
			currentDraggleX = element.x;
			
			// by center:
			//posibleDropIndex = calculateDropIndex(currentDraggleX + element.width / 2, element.y + element.height / 2);
			// by local zero point
			posibleDropIndex = calculateDropIndex(element.x, element.y);
		}
		
		private function elementResizeHandler(e:ResizeEvent):void
		{
			//updateItemModelSize(e.currentTarget as IVisualElement);
			//alignItems();
		}
	}
}