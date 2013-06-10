package ru.teachbase.model
{
import ru.teachbase.utils.registerClazzAlias;

registerClazzAlias(Stream);
	
	public class Stream
	{
		public function Stream(name:String = "", uId:Number = 0)
		{
			_name = name;
			_userId = uId; 
		}
		
		private var _name:String;
		private var _userId:Number;
		
		private var _rotation:int;
		
		public function get name():String
		{
			return _name;
		}

		public function get userId():Number
		{
			return _userId;
		}

		public function set name(value:String):void{
			_name = value;
		}
		
		public function set userId(value:Number):void{
			_userId = value;
		}

		public function get rotation():int
		{
			return _rotation;
		}

		public function set rotation(value:int):void
		{
			_rotation = value;
		}


	}
}