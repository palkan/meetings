package ru.teachbase.module.documents.model
{
import flash.errors.IllegalOperationError;

import ru.teachbase.module.documents.renderers.*;

public class WorkplaceRenderers
	{
		
		public const wb:Class = BoardRenderer;
		public const document:Class = DocumentsRenderer;
        public const table:Class = DocumentsRenderer;
		public const presentation:Class = PresentationRenderer;
		public const image:Class = ImageRenderer;
		public const video:Class = VideoRenderer;
        public const audio:Class = VideoRenderer; //todo:

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

	}
}