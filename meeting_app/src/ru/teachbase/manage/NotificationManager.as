package ru.teachbase.manage
{
import ru.teachbase.core.Core;
import ru.teachbase.events.GlobalEvent;
import ru.teachbase.events.NotificationEvent;
import ru.teachbase.events.SettingsEvent;
import ru.teachbase.model.constants.NotificationTypes;
import ru.teachbase.module.notification.NotificationContainer;
import ru.teachbase.utils.shortcuts.config;
import ru.teachbase.utils.helpers.m;
import ru.teachbase.utils.helpers.notify;

CONFIG::LIVE{
    import ru.teachbase.module.settings.GlobalSettings;
}
CONFIG::RECORDING{
    import ru.teachbase.module.settings.GlobalSettingsRec;
}
	
	public class NotificationManager extends NotificationManagerBase
	{

		private var _container:NotificationContainer;
				
		public function NotificationManager()
		{
			super();
			
			GlobalEvent.addEventListener(GlobalEvent.USER_ADD, globalEventHandler); 
			GlobalEvent.addEventListener(GlobalEvent.USER_LEAVE,globalEventHandler);
			
		}
				
		
		protected function globalEventHandler(e:GlobalEvent):void{
			
			notify(NotificationTypes.ADD_USER_NOTIFICATION,(e.type === GlobalEvent.USER_ADD), e.value);
		}
		
		override protected function initialize():void
		{
			_initialized = true;
CONFIG::LIVE{
			(m(SettingsManager) as SettingsManager).addSettingsPanel(GlobalSettings);
}

CONFIG::RECORDING{
			(m(SettingsManager) as SettingsManager).addSettingsPanel(GlobalSettingsRec);
}

		}
		
		private function showContainer():void{
			if(!_container) _container = new NotificationContainer();
			_container.top = 43;
			_container.right = 14;
			Core.addToTop(_container);
			_container.dataprovider = _arrayList;
		}
		
		override protected function newNotification(evt:NotificationEvent):void{
			//if (App.room.user.role != 'admin') {return;}
			if (config(SettingsEvent.NOTIFICATION_ENABLED,1) === 1) {
				_arrayList.addItem(evt.notification);
				
				showContainer();
			}
		}
		
	}
}