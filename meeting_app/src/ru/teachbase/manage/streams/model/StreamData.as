package ru.teachbase.manage.streams.model
{
import ru.teachbase.utils.system.registerClazzAlias;

registerClazzAlias(StreamData);
	
	public class StreamData
	{
        private var _name:String;
        private var _user_id:Number;
        private var _type:String;

        public function StreamData()
		{
		}
		

		public function get name():String
		{
			return _name;
		}

		public function get user_id():Number
		{
			return _user_id;
		}

		public function set name(value:String):void{
			_name = value;
		}
		
		public function set user_id(value:Number):void{
			_user_id = value;
		}

        public function set type(value:String):void{
            _type = value;
        }

        public function get type():String {
            return _type;
        }
    }


}