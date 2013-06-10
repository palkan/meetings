package ru.teachbase.events.documents
{
import flash.events.Event;

import ru.teachbase.model.FileItem;

public class FileEvent extends Event
	{
		public static const FILE_CLICK_EVENT:String = "file_click_event";
		private var _fileItem:FileItem;
		
		public function FileEvent(type:String, fileDiscription:FileItem, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			_fileItem = fileDiscription;
		}
		
		public function get fileItem():FileItem {
			return _fileItem; 
		}
	}
}