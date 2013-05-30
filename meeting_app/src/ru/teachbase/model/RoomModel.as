package ru.teachbase.model
{
import mx.collections.ArrayCollection;
import mx.events.CollectionEvent;

import ru.teachbase.events.GlobalEvent;
import ru.teachbase.model.constants.NotificationTypes;
import ru.teachbase.model.constants.PacketType;
import ru.teachbase.utils.helpers.dispatchTraitEvent;
import ru.teachbase.utils.helpers.notify;

/**
	 * @author Teachbase (created: Apr 26, 2012)
	 */
	[Bindable]
	
	public class RoomModel
	{
		public var id:int;

		public var name:String;
		
		private var _state:uint;

        private var _settings:uint;

		/**
		 * <id:int> = instance of User
		 */		

		public var usersByID:Object = new Object();
		
		public var usersList:ArrayCollection;
		
		public var modules:Array;

		//------------ constructor ------------//
		
		public function RoomModel()
		{
			
		}
		
		//------------ initialize ------------//
		
	
		public function set users(value:Array):void
		{
			usersList = new ArrayCollection(value);
			
			for each (var usr:User in value)
				usersByID[usr.sid] = usr;
				
		}
				
		
		public function addUser(usr:User):void{
			
			if(usersByID[usr.sid]!=undefined)
				return;
			
			usersList.addItem(usr);
			usersByID[usr.sid] = usr;
			
			GlobalEvent.dispatch(GlobalEvent.USER_ADD,usersByID[usr.sid]);
		
		}
		
		
		public function removeUser(sid:Number):void{
			
			if(usersByID[sid]==undefined)
				return;
			
			
			GlobalEvent.dispatch(GlobalEvent.USER_LEAVE,usersByID[sid]);
			
			
			usersList.removeItemAt(usersList.getItemIndex(usersByID[sid]));
			usersByID[sid] = undefined;
			

		}
		
	   public function updateUser(sid:Number,property:String, value:*):Boolean{
			
			if(usersByID[sid]==undefined)
				return false;
			
			var usr:User = usersByID[sid];
			
			if(!usr.hasOwnProperty(property))
				return false;
			
			if(usr[property] == value)
				return false;
			
			var _oldPermissions:int = usr.permissions;
			var _oldRequest:int = usr.requestStatus;
			
			usr[property] = value;
			
			
			if(user.sid == usr.sid)
				user[property] = value;
			
			
			if(usr.sid === user.sid && usr.permissions != _oldPermissions)
				dispatchTraitEvent(PacketType.PERMISSSON,usr.permissions);
			
			if (user.role == "admin" && property == "requestStatus")
				handleRequestStatusChange(usr,_oldRequest);
			
			if(usr.sid != user.sid && property == "shareStatus")
				dispatchTraitEvent(PacketType.STREAM,new Stream("",sid));
			
			usersList.dispatchEvent(new CollectionEvent(CollectionEvent.COLLECTION_CHANGE));
			
			return true;
	   }
	   
	   
	   private function handleRequestStatusChange(usr:User, _oldValue:int):void{
		   
		   if (_oldValue >  usr.requestStatus)
			   return;
		   notify(NotificationTypes.PERMISSION_NOTIFICATION, String(usr.requestStatus - _oldValue), usr);
	   }
	   
	   
		public function getUserNameById(sid:Number):String{
			if (usersByID[sid]) {
				return (usersByID[sid] as User).fullName;
			}else{
				return "Unknown"
			}
		}

		public function get record():Boolean
		{
			return _record;
		}

		public function set record(value:Boolean):void
		{
			_record = value;
			
			notify(NotificationTypes.RECORD_NOTIFICATION, value)
			
		}

		public function get recordEnabled():Boolean
		{
			return _recordEnabled;
		}

		public function set recordEnabled(value:Boolean):void
		{
			_recordEnabled = value;
		}
		
		//--------------- ctrl ---------------//
		
		//------------ get / set -------------//
		
		//------- handlers / callbacks -------//
		
	}
}
