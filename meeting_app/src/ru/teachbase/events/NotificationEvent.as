package ru.teachbase.events
{
import flash.events.Event;

import ru.teachbase.model.Notification;

public class NotificationEvent extends Event
	{
		
		public static const NOTIFICATION_EVENT:String = 'notificationEvent';
	
		private var _notification:Notification;
		
		public function NotificationEvent(type:String, notification:Notification)
		{
			super(type, bubbles, cancelable);
			_notification = notification;
		}
		
		public function get notification():Notification {
			return _notification;
		}
	}
}