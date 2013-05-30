package ru.teachbase.utils.helpers
{
import ru.teachbase.core.App;
import ru.teachbase.model.Notification;
import ru.teachbase.model.User;
import ru.teachbase.model.constants.PacketType;

/**
	 * Show notification
	 * 
	 * @param component Component name/id
	 * @param element element name
	 * @type type of element (default type "" means DisplayObject; "text" - String property; "number" - Number property
	 */	
    public function	notify(notificatioType:String, body:* = null, user:User = null, allowForUsers:Boolean = false):void{
		if (App.room.user.role != 'admin' && !allowForUsers)  {
			return;
		}
		
		dispatchTraitEvent(
			PacketType.NOTIFICATION, 
			new Notification(notificatioType, body, user)
		);
	}
}