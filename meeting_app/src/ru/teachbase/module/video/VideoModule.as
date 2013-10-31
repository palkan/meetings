package ru.teachbase.module.video
{

import ru.teachbase.manage.modules.model.IModuleContent;
import ru.teachbase.manage.modules.model.Module;
import ru.teachbase.utils.shortcuts.style;

/**
	 * @author Webils (created: Mar 2, 2012)
	 */
	public final class VideoModule extends Module
	{
		
		//------------ constructor ------------//

		public function VideoModule()
		{
			super("video");
			_icon = style("video","icon");
			_iconHover = style("video","iconHover");
			singleton = true;
		}
		
		//--------------- ctrl ---------------//
		
		override protected function createInstance(instanceID:int):IModuleContent
		{
			instanceID = 1;
			var _videoPanel:VideoModuleContent = new VideoModuleContent();
			_videoPanel.instanceID = instanceID;
            _videoPanel.init();
			_instances[instanceID] = _videoPanel;
			return _videoPanel;
		}

	}
}
