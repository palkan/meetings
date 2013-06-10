package ru.teachbase.manage.session.model
{
import ru.teachbase.utils.system.registerClazzAlias;

registerClazzAlias(UserChangeData);
	
	public class UserChangeData
	{
		public var type:String;
		
		public var property:String = "";
		
		public var value:* = null;
		
		public var id:Number;
		
		
		/**
		 * 
		 * Object containing changes in room model from server
		 * 
		 * @property type A type of change, can be "userJoin", "userLeave", "userChange"
		 * @property value Depends on type
		 * 
		 */
		
		
		
		public function UserChangeData()
		{
		}
	}
}