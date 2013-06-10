package ru.teachbase.manage.streams.model
{
import ru.teachbase.utils.system.registerClazzAlias;

registerClazzAlias(StreamData);
	
	public class StreamData
	{
        private var _name:String;
        private var _sid:Number;
        private var _type:uint = 0;

        private var _rotation:int;

        public function StreamData()
		{
		}
		

		public function get name():String
		{
			return _name;
		}

		public function get sid():Number
		{
			return _sid;
		}

		public function set name(value:String):void{
			_name = value;
		}
		
		public function set sid(value:Number):void{
			_sid = value;
		}

		public function get rotation():int
		{
			return _rotation;
		}

		public function set rotation(value:int):void
		{
			_rotation = value;
		}


        public function get type():uint {
            return _type;
        }
    }


}