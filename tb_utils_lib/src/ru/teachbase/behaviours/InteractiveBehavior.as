package ru.teachbase.behaviours
{
import flash.display.InteractiveObject;
import flash.display.Stage;
import flash.events.Event;

    /**
     *
     * Basic interactive (responding to user events) behaviour.
     *
	 * @author Teachbase (created: Jan 25, 2012)
	 */
	public class InteractiveBehavior extends Behavior
	{
		//--- properties:

        /**
         *  Define whether target itself dispatches behaviour events
         */

		public var dispatchToTarget:Boolean;
		
		//--- links:
		protected var stage:Stage;
		protected var _target:InteractiveObject;
		
		//------------ constructor ------------//
		
		public function InteractiveBehavior()
		{
			super();
		}
		
		//------------ initialize ------------//
		
		override protected function initialize():void
		{
			super.initialize();
			
			if(!_target)
				return;
			
			if(!stage)
				_target.stage ? (stage = _target.stage) : _target.addEventListener(Event.ADDED_TO_STAGE, targetAddedToStageHandler);
		}
		
		override public function dispose():void
		{
			stage = null;
			_target && _target.removeEventListener(Event.ADDED_TO_STAGE, targetAddedToStageHandler);
			
			super.dispose();
		}
		
		//--------------- ctrl ---------------//
		
		override public final function dispatchEvent(event:Event):Boolean
		{
			return dispatchToTarget && _target ? _target.dispatchEvent(event) : super.dispatchEvent(event);
		}
		
		//------------ get / set -------------//
		
		/**
		 * Target for current behavior.
		 */		
		public function get target():InteractiveObject
		{
			return _target;
		}
		
		public function set target(value:InteractiveObject):void
		{
			if(_target === value)
				return;
			
			if(_target)
				dispose();
			
			_target = value as InteractiveObject;
			
			if(_target)
				initialize();
		}
		
		//------- handlers / callbacks -------//
		
		private function targetAddedToStageHandler(e:Event):void
		{
			stage = _target.stage;
			_target.removeEventListener(Event.ADDED_TO_STAGE, targetAddedToStageHandler);
			
			stage && _target && initialize();
		}
	}
}