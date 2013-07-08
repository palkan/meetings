package ru.teachbase.components
{
import flash.display.DisplayObject;
import flash.events.Event;
import flash.utils.clearTimeout;
import flash.utils.setTimeout;

import ru.teachbase.manage.modules.model.Module;

import spark.components.ToggleButton;

public class ActionBarButton extends ToggleButton
	{
		[Bindable]
		public var module:Module;
		
		[Bindable]
		public var icon:DisplayObject;
		
		[Bindable]
		public var iconOver:DisplayObject;
		
		[Bindable]
		public var iconSelected:DisplayObject;

        public var preventToggle:Boolean = false;

        private var _wasEnabled:Boolean;


        private const ENABLE_TIMEOUT:int = 2000;

        private var _tid:uint;
		
		public function ActionBarButton()
		{
			super();
            _wasEnabled = enabled;
		}

        override protected function buttonReleased():void{
           if(!enabled) return;
           if(preventToggle){
               _wasEnabled = enabled;
               enabled = false;
               dispatchEvent(new Event(Event.CHANGE));
               _tid = setTimeout(enableOnTimeout,ENABLE_TIMEOUT);
           }
           else super.buttonReleased();

        }

        override public function set selected(value:Boolean):void{

            super.selected = value;

            if(preventToggle){
                enabled = _wasEnabled;
                _tid && clearTimeout(_tid);
            }

        }


        private function enableOnTimeout():void{
            _wasEnabled && (enabled = true);
        }


	}
}