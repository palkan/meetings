package ru.teachbase.module.video
{

import ru.teachbase.manage.LayoutManager;
import ru.teachbase.module.base.IModuleContent;
import ru.teachbase.module.base.Module;
import ru.teachbase.utils.helpers.*;
import ru.teachbase.utils.shortcuts.style;

/**
	 * @author Webils (created: Mar 2, 2012)
	 */
	public final class VideoModule extends Module
	{
		
		//------------ constructor ------------//

		
		private var _videoPanel:VideoModuleContent;
		
		
		public function VideoModule()
		{
			super("video");
			_icon = style("video","icon");
			_iconHover = style("video","iconHover");
			singleton = true;
		}	
		
		//------------ initialize ------------//
		
		override public function initializeModule(manager:LayoutManager):void
		{
			super.initializeModule(manager);
		}
		
		//--------------- ctrl ---------------//
		
		override protected function createInstance(instanceID:int):IModuleContent
		{
			instanceID = 1;
			_videoPanel = new VideoModuleContent();
			_videoPanel.instanceID = instanceID;
			instances[instanceID] = _videoPanel;
			return _videoPanel;
		}
		
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
