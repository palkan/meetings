package ru.teachbase.model
{
import ru.teachbase.utils.registerClazzAlias;

registerClazzAlias(Packet);
	registerClazzAlias(Packet$);
	
	/**
	 * Read-only serializable object
	 * @author webils (created: May 4, 2012)
	 */
	public class Packet extends Object
	{
		protected var _timeS:Number = -1;// changing an server
		protected var _timeL:Number = -1;
		
		protected var _type:String;
		protected var _senderID:Number = 0;
		protected var _recipientID:* = 0;
		protected var _data:Object;
		
		protected var _id:*;
		protected var _minstance:*;
		protected var _system:Boolean = false;
		
		//------------ constructor ------------//
		
		public function Packet(type:String = null, data:Object = null, to:* = 0, minstance:uint = 0, sys:Boolean = true)
		{
			super();
			_type = type;
			_senderID = from;
			_recipientID = to;
			_data = data;
			_timeL = new Date().time;
			_minstance = minstance;
			_system = sys;
		}
		
		//------------ initialize ------------//
		
		//--------------- ctrl ---------------//
		
		public function clone():Packet
		{
			const result:Packet = new Packet(_type, _data, _recipientID);
			result._senderID = _senderID;
			result._timeL = _timeL;
			result._timeS = _timeS;
			return result;
		}
		
		public function toString():String
		{
			return '[object Packet (' + _type + ') > ' + _recipientID + ']';
		}
		
		//------------ get / set -------------//
		
		/**
		 * Client Time when packet sent
		 */		
		public function get timeL():Number
		{
			return _timeL;
		}
		
		/**
		 * Server Time when packet received
		 */		
		public function get timeS():Number
		{
			return _timeS;
		}

		public function get type():String
		{
			return _type;
		}
		
		public function get from():Number
		{
			return _senderID;
		}
		
		/**
		 *  
		 * @return receipient id; can be Number or Array of Numbers
		 * 
		 */
		public function get to():*
		{
			return _recipientID;
		}
		
		public function get data():Object
		{
			return _data;
		}
		
		
		public function get id():*
		{
			return _id;
		}
		
		public function get minstance():*
		{
			return _minstance;
		}
		
		public function get system():Boolean
		{
			return _system;
		}
		
		//------- for native serialization -------//
		
		public function set timeL(value:Number):void{}
		public function set timeS(value:Number):void{}
		public function set type(value:String):void{}
		public function set from(value:Number):void{}
		public function set to(value:*):void{}
		public function set data(value:Object):void{}

		public function set id(value:*):void{}
		public function set minstance(value:*):void{}
		public function set system(value:Boolean):void{}
		
		//------- handlers / callbacks -------//
	}
}
