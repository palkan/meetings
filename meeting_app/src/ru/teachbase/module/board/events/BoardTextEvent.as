package ru.teachbase.module.board.events
{
import flash.events.Event;

public class BoardTextEvent extends Event
	{
		
		public static const UPDATE:String = "update";
		
		public function BoardTextEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}