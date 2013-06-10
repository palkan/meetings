package ru.teachbase.model
{
	
	/**
	 * Private editable serializable object
	 *  (created: May 4, 2012)
	 */
	internal final dynamic class Packet$ extends Packet
	{
		
		//------------ constructor ------------//
		
		public function Packet$()
		{
			super();
		}
		
		//------------ initialize ------------//
		
		//--------------- ctrl ---------------//
		
		override public function toString():String
		{
			return super.toString() + '*';
		}
		
		//------------ get / set -------------//
		
		override public function set timeL(value:Number):void
		{
			_timeL = value;
		}
		
		override public function set timeS(value:Number):void
		{
			_timeS = value;
		}
		
		override public function set type(value:String):void
		{
			_type = value;
		}
		
		override public function set from(value:Number):void
		{
			_senderID = value;
		}
		
		override public function set to(value:*):void
		{
			_recipientID = value;
		}
		
		override public function set data(value:Object):void
		{
			_data = value;
		}
		
		
		override public function set id(value:*):void
		{
			_id = value;
		}
		override public function set minstance(value:*):void
		{
			_minstance = value;
		}
		override public function set system(value:Boolean):void
		{
			_system = value;
		}
		
		//------- handlers / callbacks -------//
		
	}
}