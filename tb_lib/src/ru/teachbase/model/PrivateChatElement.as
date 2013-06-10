package ru.teachbase.model
{
import ru.teachbase.core.App;

public class PrivateChatElement
	{
		private var _chat:Array;
		private var _userId:Number;
		private var _unreadMessages:int = 0;
		private var _totalMessages:int;
		
		public function PrivateChatElement($userId:Number)
		{
			_userId = $userId;
			_chat = new Array();
		}

		public function get totalMessages():int
		{
			return _totalMessages;
		}

		public function set totalMessages(value:int):void
		{
			_totalMessages = value;
		}

		public function get unreadMessages():int
		{
			return  _unreadMessages;
		}
		
		public function set unreadMessages(value:int):void{
			_unreadMessages = value;	
		}

		public function get userName():String
		{
			const user:User = App.room.usersByID[_userId];
			return user.fullName;
		}

		public function get userId():Number
		{
			return _userId;
		}

		public function get chat():Array
		{
			return _chat;
		}

	}
}