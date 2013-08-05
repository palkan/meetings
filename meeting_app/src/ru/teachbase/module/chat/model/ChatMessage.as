package ru.teachbase.module.chat.model
{
import ru.teachbase.utils.system.registerClazzAlias;

registerClazzAlias(ChatMessage);
	
	
	public class ChatMessage
	{
        /**
         *  True chat message
         */

		public static const MESSAGE:String = 'tb:chat:message';

        /**
         *  Typing message
         */

		public static const TYPING:String = 'tb:chat:typing';


        /**
         *  Clear chat message
         */

		public static const CLEAR:String = "tb:chat:clear";

        private var _id:int;
		private var _uid:Number;
		private var _body:String;
		private var _timestampS:Number = 0;
		private var _name:String;
		private var _timestampL:Number;
		private var _type:String;
        private var _roomId:Number;
        private var _color:String;
		
		
		public function ChatMessage(uid:Number = 0, roomId:Number = 0,  type:String = ChatMessage.MESSAGE, name:String = "", body:String = "", color:String = "")
		{
			
			_uid = uid;
			_roomId = roomId;
            _body = body;
			_name = name;
			_type = type;
            _color = color;

			_timestampL = (new Date()).time;
		}

        public function toString():String{

            return _name+' ['+(new Date(_timestampS).toUTCString())+']: '+_body;

        }

        public function toCSVString():String{

            return _name+';'+(new Date(_timestampS).toUTCString())+';'+_body;

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

        public function get roomId():Number {
            return _roomId;
        }

        public function set roomId(value:Number):void {
            _roomId = value;
        }

        public function get id():int {
            return _id;
        }

        public function set id(value:int):void {
            _id = value;
        }

        /**
         * Color of name-date block of a message.
         */

        public function get color():String {
            return _color;
        }

        public function set color(value:String):void {
            _color = value;
        }
    }
}