package ru.teachbase.manage
{
import mx.rpc.Responder;

import ru.teachbase.core.App;
import ru.teachbase.events.RoomEvent;
import ru.teachbase.model.RoomChangeData;
import ru.teachbase.model.User;
import ru.teachbase.model.constants.UserRoles;
import ru.teachbase.traits.RoomTrait;
import ru.teachbase.utils.Permissions;
import ru.teachbase.utils.objectSmartGetValue;

CONFIG::RECORDING{
    import ru.teachbase.model.RecordModel;
}
/**
	 * @author Webils (created: Jul 5, 2012)
	 */
	public final class RoomModelManager extends Manager
	{
		private const trait:RoomTrait = TraitManager.instance.createTrait(RoomTrait) as RoomTrait;
		//------------ constructor ------------//
		
		public function RoomModelManager()
		{
			super();
		}
		
		//------------ initialize ------------//
		
		override protected function initialize():void
		{
			if(initialized)
				return;
			
			new RoomChangeData();
			new User();
			
			trait.initialize();
			trait.call("get_history", new Responder(getUsersResultCallback, getUsersError),"users");
		
		}
	
		protected function onRoomUsersChanged(e:RoomEvent):void
		{
			
			for each(var d:Object in e.data)
				processData(d as RoomChangeData);
			
			
			
		}
		
		private function getUsersError(error:*):void
		{
			//TODO add handler
							
		}
		
		
		private function processData(data:RoomChangeData):void{
			
			switch(data.type){
				case "userJoin":
					App.room.addUser(data.value);
					break;
				case "userLeave":
					App.room.removeUser(data.id);
					break;
				case "userChange":
					App.room.updateUser(data.id, data.property, data.value);
					break;
				case "record":
					App.room.record = data.value;
					break;
				
			}
			
			
		}
		
		//--------------- ctrl ---------------//

CONFIG::LIVE{
		
		/**
		 * Call start_record method on server if true, otherwise call stop_record
		 * 
		 */		
		
		public function startRecord(flag:Boolean):void{
			
			
			if(!App.room.record && App.room.user.role === UserRoles.ADMIN && flag){
				trait.call("start_record");
			}
			
			if(App.room.record && App.room.user.role === UserRoles.ADMIN && !flag){
				trait.call("stop_record");
			}
			
				
		}
		
		
		/**
		 * Call this function to notify other users about a new user joined 
		 *  
		 * 
		 */		
		
		
		public function userReady():void{
			App.room.user && trait.call("user_ready",null,App.room.user.sid);
		}	
		
		/**
		 * Call this function to change user role. 
		 * 
		 * 
		 * @param sid user session id
		 * @param role new user role
		 * 
		 */		
		
		public function setUserRole(sid:Number, role:String):void{
			
			if(App.room.usersByID[sid] && App.room.user.role === UserRoles.ADMIN && App.room.usersByID[sid].role != role)
				trait.call("set_role",null,sid,role);
			
		}
		
		
		/**
		 * Call this function to make permission request or cancel existing one.
		 *  
		 * @param value permission mask (use Permissions class constants)
		 * @param flag  to cancel request set <i>flag</i> to <i>false</i>
		 * 
		 */		
		
		
		public function setRequest(value:uint, flag:Boolean = true, id:Number = 0):void{
			if(!id)
				id = App.room.user.sid;
			
			if(!App.room.usersByID[id])
				return;
			
			var _usr:User = App.room.usersByID[id] as User;
			
			if(Permissions.hasRight(value, _usr.requestStatus) == flag)
				return;
			
			value = _usr.requestStatus + Math.pow(-1,int(flag)+1)*value;
			
			//App.room.updateUser(App.room.user.sid,{property:"requestStatus", value:value});
			trait.call("request_status",null,_usr.sid,value);
			
		}
		
		/**
		 * Call this function to add or cancel user's rights (permissions).
		 *  
		 * @param sid user session id
		 * @param rights permission mask (use Permissions class constants)
		 * @param flag to cancel permission set to <i>false</i>
		 * 
		 */		
		
		public function setUserRights(sid:Number, rights:uint, flag:Boolean = true):void{
			if(!App.room.usersByID[sid] || App.room.user.role != UserRoles.ADMIN)
				return;
			
			var _usr:User = App.room.usersByID[sid] as User;
			
			
			if(Permissions.hasRight(rights,_usr.shareRights) == flag)
				return;
			
			if (flag && rights === Permissions.CAMERA && !Permissions.hasRight(Permissions.MIC,_usr.shareRights))
				rights += Permissions.MIC;
			
			rights = _usr.shareRights + Math.pow(-1,int(flag)+1)*rights;
			
			trait.call("set_rights",null,sid,rights); 
			
			
		}
		
		
}


		
		//------------ get / set -------------//
		
		
		private function getUsersResultCallback(room_model:Object):void
		{
			
			App.room.users = objectSmartGetValue(room_model,"users",[],function(a:*):Boolean{ return (a is Array);});
			
			App.room.record = objectSmartGetValue(room_model, "record", false);
			
			App.room.modules = objectSmartGetValue(room_model, "modules", []);

CONFIG::LIVE{
			App.room.recordEnabled = objectSmartGetValue(room_model, "recordEnabled", false);
			(App.room.usersByID[App.room.user.sid] as User).iam = true;
}
			trait.addEventListener(RoomEvent.USERS_CHANGED,onRoomUsersChanged);

CONFIG::RECORDING{
			var _start:Number = objectSmartGetValue(room_model,"start_time",NaN);
			var _stop:Number = objectSmartGetValue(room_model,"stop_time",NaN);
			
			var _d:Number = NaN;
			
			if(!isNaN(_start) && !isNaN(_stop))
				_d = Math.floor((_stop - _start)/1000000);
			
			if(!isNaN(_d))
				App.room.recordModel = new RecordModel(_d);
				
}	
			
			_initialized = true;
			
			trait.readyToReceive = true;
			
		}
		
		override public function dispose():void{
			App.room.user = null;
			_initialized = false;
		}
		
			
	}
}
