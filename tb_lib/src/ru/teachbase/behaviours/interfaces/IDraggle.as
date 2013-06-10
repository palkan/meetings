package ru.teachbase.behaviours.interfaces
{

import flash.display.IBitmapDrawable;

import mx.core.IVisualElement;

import ru.teachbase.behaviours.DragBehavior;

/**
	 * @author Teachbase (created: Jan 27, 2012)
	 */
	public interface IDraggle extends IVisualElement, IBitmapDrawable
	{
		//------------ initialize ------------//
		
		//--------------- ctrl ---------------//
		
		/**
		 * Required for implementations!
		 */		
		function getSnapshot():IDraggleSnapshot;
		
		//------------ get / set -------------//
		
		/**
		 * my DragBehavior instance
		 * @see ru.teachbase.behaviors.DragBehavior
		 */		
		function get dragBehavior():DragBehavior;
		
		/**
		 * state of my dragBehavior
		 * @see ru.teachbase.behaviors.DragState
		 */		
		function get dragState():String;
		
	}
}