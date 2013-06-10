package ru.teachbase.model
{
import flash.net.NetStream;

public dynamic class LocalStream
	{
		
		private var _stream:NetStream;
		private var _userId:Number;
		
		private var _active:Boolean = false;
		protected var _name:String;
		
		private var _rotation:int = 0;
		
		public var time:int;
		
		public function LocalStream(stream:NetStream = null, userId:Number = 0)
		{
			_stream = stream;
			_userId = userId;
		}

		public function get userId():Number
		{
			return _userId;
		}

		public function set userId(value:Number):void
		{
			_userId = value;
		}

		public function get stream():NetStream
		{
			return _stream;
		}

		public function set stream(value:NetStream):void
		{
			_stream = value;
		}

		public function get active():Boolean
		{
			return _active;
		}

		public function set active(value:Boolean):void
		{
			_active = value;
		}

		public function get name():String
		{
			return _name;
		}

		public function set name(value:String):void
		{
			_name = value;
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