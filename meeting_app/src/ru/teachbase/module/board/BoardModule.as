package ru.teachbase.module.board
{
import ru.teachbase.manage.modules.model.Module;
import ru.teachbase.utils.helpers.*;
import ru.teachbase.utils.shortcuts.style;

/**
	 * @author Aleksandr Kozlovskij (created: Mar 2, 2012)
	 */
	public final class BoardModule extends Module
	{
		
		//------------ constructor ------------//
		
		public function BoardModule()
		{
			super("board");
			// TODO: replace icon
			_icon = style("workplace","icon");
			_iconHover = style("workplace","iconHover");
		}
		
		//------------ initialize ------------//
		
		/*override public function initializeModule(manager:LayoutModelManager):void
		{
			super.initializeModule(manager);
		}*/
		
		//--------------- ctrl ---------------//
		
		/*override protected function createInstance(instanceID:int):IModuleContent
		{
			const result:BoardContent = new BoardContent();
		//	result.client = _serviceClient as BoardClient;
			return result;
		}*/
		
		/*public function getVisual(instance:int):IBinaryTreeLayoutElement
		{
			return null;
		}*/
		
		//------------ get / set -------------//
		
		/*public function get icon():BitmapData
		{
			return null;
		}
		
		public function get serviceClient():IServiceClient
		{
			return null;
		}*/
		
		//------- handlers / callbacks -------//
		
	}
}