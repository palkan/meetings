package ru.teachbase.utils.helpers
{
import ru.teachbase.model.App;
import ru.teachbase.model.User;

/**
	 * Show notification
	 * 
	 * @param component Component name/id
	 * @param element element name
	 * @type type of element (default type "" means DisplayObject; "text" - String property; "number" - Number property
	 */	
    public function	notify(notificatioType:String, body:* = null, user:User = null, allowForUsers:Boolean = false):void{
		if (!App.user.isAdmin() && !allowForUsers)  {
			return;
		}
		
	    //TODO: show notification
	}
}