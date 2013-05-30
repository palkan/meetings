package ru.teachbase.module
{
import flash.errors.IllegalOperationError;

import ru.teachbase.module.board.BoardModule;
import ru.teachbase.module.chat.ChatModule;
import ru.teachbase.module.documents.DocumentsModule;
import ru.teachbase.module.screenshare.ScreenShareModule;
import ru.teachbase.module.users.UsersModule;
import ru.teachbase.module.video.VideoModule;

public final class ModuleClass
	{
		
		private static const instance:ModuleClass = new ModuleClass();
		
		public const video:Class = VideoModule;
		
		public const chat:Class = ChatModule;
		
		public const users:Class = UsersModule;
		
		public const board:Class = BoardModule;
		
		public const docs:Class = DocumentsModule;
		
		public const screenshare:Class = ScreenShareModule;
		
		//------------ constructor ------------//
		
		public function ModuleClass()
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
		
		
		//------------ get / set -------------//
		
		//------- handlers / callbacks -------//
		
	}
}