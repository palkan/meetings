package ru.teachbase.model
{
import ru.teachbase.utils.Permissions;
import ru.teachbase.utils.registerClazzAlias;

registerClazzAlias(User);
	
	/**
	 * @author Webils (created: Apr 27, 2012)
	 */
	public class User
	{
		public var id:int;
		public var sid:Number;
		
		private var _role:String = "user";
		
		public var name:String;
		public var fullName:String;
		public var suffix:int;
		
		public var avatarURL:String;
		
		public var iam:Boolean = false;		
		
		/**
		 * "guest" or "user" 
		 */
		public var status:String = "user";
		
		/**
		 * "cam,mic,scr" now sharing
		 * @see ru.teachbase.model.constants.SharingDeviceFlag
		 */		
		[Bindable]
		public var shareStatus:uint;
		
		[Bindable]
		public var requestStatus:uint = 0;
		
		[Bindable]
		private var _shareRights:uint = 0;
		
		
		//[Bindable]
		//public var allowNotifications:Boolean = true;
		
		/**
		 * User's rights: role|cam|mic|doc, e.g. <i>admin</i> always has 2#1111 (15).
		 * 
		 * User can have 2#0010 (2) - only mic available. 
		 * 
		 */
		[Bindable]
		public var permissions:uint = 0;
	
		//------------ constructor ------------//
		
		
		public function User()
		{
		}
		
	
		
		//------------ initialize ------------//
		
		//--------------- ctrl ---------------//
		
		
		//------------ get / set -------------//
		
		//------- handlers / callbacks -------//
		
		/**
		 * admin
		 */
		[Bindable]
		public function get role():String
		{
			return _role;
		}

		/**
		 * @private
		 */
		public function set role(value:String):void
		{
			
			if(_role === value)
				return;
			
			_role = value;
			
			if(value == "admin")
				permissions = Permissions.ADMIN;
			else{
				permissions = 0;
				_shareRights = 0;
			}
		}

		/**
		 * "cam,mic,scr" is available devices for share
		 * @see ru.teachbase.model.constants.SharingDeviceFlag
		 */
		
		[Bindable]
		public function get shareRights():uint
		{
			return _shareRights;
		}

		/**
		 * @private
		 */
		public function set shareRights(value:uint):void
		{
			
			if(role == "admin")
				return;
			
			permissions-=_shareRights;
			
			_shareRights = value;
			
			permissions+=_shareRights;
			
		if(requestStatus & value) {
				requestStatus = 0;
			}
		}
		
	}
}
