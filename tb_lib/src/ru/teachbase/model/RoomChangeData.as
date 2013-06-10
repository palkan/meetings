package ru.teachbase.model
{
import ru.teachbase.utils.registerClazzAlias;

registerClazzAlias(RoomChangeData);
	
	public class RoomChangeData
	{
		public var type:String;
		
		public var property:String = "";
		
		public var value:* = null;
		
		public var id:Number;
		
		
		/**
		 * 
		 * Object containing changes in room model from server
		 * 
		 * @property type A type of change, can be "userJoin", "userLeave", "userChange", "userRole", "record"
		 * @property value
		 * 
		 * Depends on type
		 * 
		 * 
		 * 
		 */
		
		
		
		public function RoomChangeData()
		{
		}
	}
}