package ru.teachbase.manage.notifications
{
import ru.teachbase.constants.NotificationTypes;
import ru.teachbase.events.GlobalEvent;
import ru.teachbase.manage.*;
import ru.teachbase.manage.notifications.events.NotificationEvent;
import ru.teachbase.manage.settings.SettingsManager;
import ru.teachbase.module.notification.NotificationContainer;
import ru.teachbase.module.settings.GlobalSettings;
import ru.teachbase.module.settings.events.SettingsEvent;
import ru.teachbase.utils.helpers.notify;
import ru.teachbase.utils.shortcuts.config;

public class NotificationManager extends Manager
	{

		private var _container:NotificationContainer;
				
		public function NotificationManager(registered:Boolean = false)
		{
			super(registered);
			

			
		}
				
		
		protected function globalEventHandler(e:GlobalEvent):void{
			
			notify(NotificationTypes.ADD_USER_NOTIFICATION,(e.type === GlobalEvent.USER_ADD), e.value);
		}
		
		override protected function initialize():void
		{
            GlobalEvent.addEventListener(GlobalEvent.USER_ADD, globalEventHandler);
            GlobalEvent.addEventListener(GlobalEvent.USER_LEAVE,globalEventHandler);
			_initialized = true;
		}
		
		private function showContainer():void{
			/*if(!_container) _container = new NotificationContainer();
			_container.top = 43;
			_container.right = 14;
			//Core.addToTop(_container);
			_container.dataprovider = _arrayList;*/
		}
		
		 protected function newNotification(evt:NotificationEvent):void{
			/*//if (App.room.user.role != 'admin') {return;}
			if (config(SettingsEvent.NOTIFICATION_ENABLED,1) === 1) {
				_arrayList.addItem(evt.notification);
				
				showContainer();
			} */
		}
		
	}
}