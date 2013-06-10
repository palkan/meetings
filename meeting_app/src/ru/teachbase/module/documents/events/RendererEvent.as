package ru.teachbase.module.documents.events
{
import flash.events.Event;

public class RendererEvent extends Event
	{
		
		public static const INITIALIZED:String = "init";
		
		public function RendererEvent(type:String)
		{
			super(type, bubbles, cancelable);
		}
	}
}