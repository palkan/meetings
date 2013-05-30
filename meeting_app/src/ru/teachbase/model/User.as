package ru.teachbase.model
{
import flash.events.Event;

import ru.teachbase.utils.Permissions;
import ru.teachbase.utils.system.registerClazzAlias;

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
		

        private var _shareStatus:uint;

        private var _requestStatus:uint = 0;

		private var _shareRights:uint = 0;

        private var _permissions:uint = 0;
	
		//------------ constructor ------------//
		
		
		public function User()
		{
		}
		
	
		
		//------------ initialize ------------//
		
		//--------------- ctrl ---------------//
		
		
		//------------ get / set -------------//
		
		//------- handlers / callbacks -------//
		

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
				_permissions = Permissions.ADMIN;
			else{
				_permissions = 0;
				_shareRights = 0;
			}
		}

		/**
		 * "cam,mic,scr" is available devices for share
		 * @see ru.teachbase.model.constants.SharingDeviceFlag
		 */
		
		[Bindable(event="userShareRightsUPD")]
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
			
			_permissions-=_shareRights;
			
			_shareRights = value;
			
			_permissions+=_shareRights;
			
		    if(_requestStatus & value) {
				_requestStatus = 0;
			}

            dispatchEvent(new Event("userShareRightsUPD"));
        }
        /**
         * "cam,mic,scr" now sharing
         * @see ru.teachbase.model.constants.SharingDeviceFlag
         */
        [Bindable(event="userShareStatusUPD")]
        public function get shareStatus():uint {
            return _shareStatus;
        }

        public function set shareStatus(value:uint):void {
            _shareStatus = value;
            dispatchEvent(new Event("userShareStatusUPD"));
        }

        [Bindable(event="userRequestStatusUPD")]
        public function get requestStatus():uint {
            return _requestStatus;
        }

        public function set requestStatus(value:uint):void {
            _requestStatus = value;
            dispatchEvent(new Event("userRequestRightsUPD"));
        }

        /**
         * User's rights: role|cam|mic|doc, e.g. <i>admin</i> always has 2#1111 (15).
         * User can have 2#0010 (2) - only mic available.
         */

        [Bindable(event="userPermissionsUPD")]
        public function get permissions():uint {
            return _permissions;
        }

        public function set permissions(value:uint):void {
            _permissions = value;
            dispatchEvent(new Event("userPermissionsUPD"));
        }
    }
}
