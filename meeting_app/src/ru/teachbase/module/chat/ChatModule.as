package ru.teachbase.module.chat
{
import ru.teachbase.manage.modules.model.IModuleContent;
import ru.teachbase.manage.modules.model.Module;
import ru.teachbase.utils.shortcuts.style;

/**
	 * @author Aleksandr Kozlovskij (created: Mar 2, 2012)
	 */
	public final class ChatModule extends Module
	{
		
		//------------ constructor ------------//

		
		
		public function ChatModule()
		{
			super('chat');
			_icon = style('chat',"icon");
			_iconHover = style('chat',"iconHover");
			
			singleton = true;
			
		}

		
		//--------------- ctrl ---------------//
		
		override protected function createInstance(instanceID:int):IModuleContent
		{
			//TEMP
			instanceID = 1;
			const result:ChatContent = new ChatContent();
			result.instanceID = instanceID;
            result.init();
			_instances[instanceID] = result;
			return result;
		}
		
		//------- handlers / callbacks -------//
		
		
		
		
		
		
		
	}
}