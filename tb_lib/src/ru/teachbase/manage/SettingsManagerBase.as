package ru.teachbase.manage
{
import ru.teachbase.events.ChangeEvent;
import ru.teachbase.model.Setting;
import ru.teachbase.utils.registerClazzAlias;

public class SettingsManagerBase extends Manager
	{
		
		//public static var instance:SettingsManagerBase = new SettingsManagerBase();
		
		private var _settingsContents:Array = new Array();
		
		public function SettingsManagerBase()
		{
			registerClazzAlias(Setting)
			super();
			/*if (instance) {
				throw new IllegalOperationError ("SettingsManager is singleton, please call SettingsManager.instance");
			}*/
		}
		
		override protected function initialize():void{
			_initialized = true;
		}

		private function changeHandler(evt:ChangeEvent):void{
		}

	}
}