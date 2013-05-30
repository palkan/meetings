package ru.teachbase.model
{
import ru.teachbase.utils.registerClazzAlias;

registerClazzAlias(ChatMessage);
	
	
	public class ChatMessage
	{
		
		public static const MESSAGE:String = 'message';
		public static const TYPE_STARTED:String = 'typeStarted';
		public static const TYPE_STOPPED:String = 'typeStopped';
		
		public static const CLEAR:String = "clear";
		
		private var _uid:Number;
		private var _body:String;
		private var _timestampS:Number = 0;
		private var _name:String;
		private var _timestampL:Number;
		private var _type:String;
		
		private var _to:Number = 0;
		
		
		public function ChatMessage(uid:Number = 0, type:String = ChatMessage.MESSAGE, name:String = "", body:String = "")
		{
			
			this.uid = uid;
			this.body = body;
			this.name = name;
			this.type = type;
			this.timestampL = (new Date()).time;		
		}

		public function get uid():Number
		{
			return _uid;
		}

		public function set uid(value:Number):void
		{
			_uid = value;
		}

		public function get body():String
		{
			return _body;
		}

		public function set body(value:String):void
		{
			_body = value;
		}

		public function get timestampL():Number
		{
			return _timestampL;
		}

		public function set timestampL(value:Number):void
		{
			_timestampL = value;
		}

		public function get name():String
		{
			return _name;
		}

		public function set name(value:String):void
		{
			_name = value;
		}

		public function get timestampS():Number
		{
			return _timestampS;
		}

		public function set timestampS(value:Number):void
		{
			_timestampS = value;
		}

		public function get type():String
		{
			return _type;
		}

		public function set type(value:String):void
		{
			_type = value;
		}

		/**
		 * <b>Only for private chat.</b>
		 * 
		 * Sid of the recipient.
		 *  
		 * @return 
		 * 
		 */
		public function get to():Number
		{
			return _to;
		}

		public function set to(value:Number):void
		{
			_to = value;
		}


	}
}