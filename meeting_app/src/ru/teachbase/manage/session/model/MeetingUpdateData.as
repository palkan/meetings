package ru.teachbase.manage.session.model
{
import ru.teachbase.utils.system.registerClazzAlias;

registerClazzAlias(MeetingUpdateData);
	
	public class MeetingUpdateData
	{
		public var type:String;
		
		public var value:* = null;

		/**
		 * 
		 * Object containing changes in room model from server
		 * 
		 * @property type A type of change, can be "settings", "state"
		 * @property value Depends on type
		 * 
		 */
		
		
		
		public function MeetingUpdateData()
		{
		}
	}
}