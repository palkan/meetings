package ru.teachbase.module.documents.model
{
import flash.errors.IllegalOperationError;

import ru.teachbase.module.documents.renderers.*;

public class WorkplaceRenderers
	{
		
		public const whiteboard:Class = BoardRenderer;
		public const docs:Class = DocumentsRenderer;
		public const pres:Class = PresentationRenderer;
		public const img:Class = ImageRenderer;
		public const youTube_video:Class = YouTubeVideoRenderer;
		public const video:Class = VideoRenderer;
		private static var instance:WorkplaceRenderers = new WorkplaceRenderers();
		
		public function WorkplaceRenderers()
		{
			if(instance)
				throw new IllegalOperationError(this + ' is a Singleton. Use static methods and properties.');
		}
		
		//------------ initialize ------------//
		
		//--------------- ctrl ---------------//
		
		/** 
		 * Get Class by module id (e.g. received from server)
		 * 
		 * @param id String
		 * 
		 */	
		
		public static function getClassById(id:String):Class{
			if(instance.hasOwnProperty(id))
				return instance[id];
			else
				return null;
			
		}
		
		/**
		 * Get class by document extension
		 *  
		 * @param ext
		 * @return 
		 * 
		 */		
		public static function getClassByDocExt(ext:String):Class{
			
			var id:String;
			
			switch(ext){
				case "ppt":
				case "pptx":
				case "odp":
					id = "pres";
				break;
				case "doc":
				case "docx":
				case "odt":
				case "ods":
				case "xls":
				case "xlsx":
				case "pdf":
					id = "docs";
				break;
				case "jpg":
				case "jpeg":
				case "gif":
				case "png":
				case "bmp":
					id="img";
				break;
				case "mp4":
				case "flv":
				case "mp3":
				default:
					id="undefined";
				break;
			}
			
			if(instance.hasOwnProperty(id))
				return instance[id];
			else
				return null;
			
		}
	}
}