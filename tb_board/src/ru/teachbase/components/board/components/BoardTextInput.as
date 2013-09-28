package ru.teachbase.components.board.components
{
import flash.display.DisplayObjectContainer;
import flash.events.Event;
import flash.events.FocusEvent;
import flash.events.TimerEvent;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFieldType;
import flash.text.TextFormat;
import flash.utils.Timer;

import ru.teachbase.components.board.events.BoardTextEvent;
import ru.teachbase.components.board.model.Figure;
import ru.teachbase.components.board.instruments.TextInstrument;
import ru.teachbase.utils.extensions.FocusTextField;

[Event(name="update", type="ru.teachbase.components.board.events.BoardTextEvent")]
	
	public class BoardTextInput extends FocusTextField
	{
		
		
		
		private var back_txt:TextField;
		private var _container:DisplayObjectContainer;
		
		private var _changed:Boolean = false;
		
		private var timer:Timer = new Timer(TextInstrument.SEND_TIMEOUT);
		
		public function BoardTextInput(container:DisplayObjectContainer)
		{
			super();
			_container = container;
			
			
			var _tf:TextFormat = new TextFormat();
			
			_tf.font = "_sans";
			_tf.color = (container as Figure).color;
			
			back_txt = new TextField();
			back_txt.alpha = 0.3;
			back_txt.defaultTextFormat = _tf;
			back_txt.autoSize = TextFieldAutoSize.LEFT;
			back_txt.selectable = false;
			back_txt.text = "Type here...";
			
			back_txt.x = this.x;
			back_txt.y = this.y;
			
			container.addChild(back_txt);
			
			
			
			
			defaultTextFormat = _tf;
			type = TextFieldType.INPUT;
			multiline = true;
			autoSize = TextFieldAutoSize.LEFT;
			wordWrap = true;
			borderColor = 0x1c9de8;

			width = 60;
			
			addEventListener(FocusEvent.FOCUS_IN,focusHandler);
			addEventListener(FocusEvent.FOCUS_OUT,focusHandler);
			
			
			
		}
		
		protected function focusHandler(event:FocusEvent):void
		{
			border = (event.type === FocusEvent.FOCUS_IN);
			
			if(border){
				addEventListener(Event.CHANGE, onTextChange);
				
				
				timer.addEventListener(TimerEvent.TIMER,timerHandler);
				timer.start();
				
			}else{
				removeEventListener(Event.CHANGE, onTextChange);
				timer.stop();
				timer.removeEventListener(TimerEvent.TIMER,timerHandler);
				timerHandler();
				if(back_txt){
					_container.removeChild(this);
					_container.removeChild(back_txt);	
				}
			}
			
			
		}
		
		private function timerHandler(event:TimerEvent = null):void
		{
			
			if(_changed){
				
				dispatchEvent(new BoardTextEvent(BoardTextEvent.UPDATE));
				
				_changed = false;
			}
			
		}
		
		protected function onTextChange(event:Event = null):void
		{
			
			if(back_txt && _container.removeChild(back_txt)){
				back_txt = null;
				wordWrap = false;
			}
			_changed = true;
			
		}	
		
		
		override public function set text(value:String):void{
			
			super.text = value;
			
			onTextChange();
			
		}
	
	}
}