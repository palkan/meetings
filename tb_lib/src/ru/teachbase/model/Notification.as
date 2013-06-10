package ru.teachbase.model
{
	public class Notification
	{
		private var _type:String;
		private var _value:*;
		private var _user:User;
		
		public function Notification(type:String, value:*, user:User = null):void
		{
			_type = type;
			_value = value;
			_user = user;
		}
		
		
		public function get value():*
		{
			return _value;
		}

		public function get type():String
		{
			return _type;
		}

		public function get user():User
		{
			return _user;
		}


	}
}