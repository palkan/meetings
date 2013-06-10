package ru.teachbase.manage
{
import mx.collections.ArrayList;

import ru.teachbase.events.NotificationEvent;
import ru.teachbase.traits.NotificationTrait;

public class NotificationManagerBase extends Manager
	{

		protected var _trait:NotificationTrait = TraitManager.instance.createTrait(NotificationTrait) as NotificationTrait;
	
		protected var _arrayList:ArrayList = new ArrayList();

		
		public function NotificationManagerBase(...deps)
		{
			super(deps);
			_trait.addEventListener(NotificationEvent.NOTIFICATION_EVENT, newNotification);			
			
		}
				
		override protected function initialize():void
		{
			_initialized = true;
		}
		
		
		protected function newNotification(evt:NotificationEvent):void{
			//TODO override this!
		}
		
	}
}