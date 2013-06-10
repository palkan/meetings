package ru.teachbase.components
{
import flash.display.DisplayObject;

import ru.teachbase.manage.modules.model.Module;

import spark.components.ToggleButton;

public class ActionBarButton extends ToggleButton
	{
		[Bindable]
		public var module:Module;
		
		[Bindable]
		public var icon:DisplayObject;
		
		[Bindable]
		public var iconOver:DisplayObject;
		
		[Bindable]
		public var iconSelected:DisplayObject;
		
		public function ActionBarButton()
		{
			super();
		}
	}
}