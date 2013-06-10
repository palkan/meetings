package ru.teachbase.traits
{
import flash.events.TimerEvent;
import flash.utils.Timer;

import ru.teachbase.utils.chain.Chain;
import ru.teachbase.utils.chain.ChainMode;

/**
	 * @author webils (created: May 2, 2012)
	 */
	public class ChainTrait extends RTMPListener
	{
		private const sendTimer:Timer = new Timer(150);
		
		//EXTND: Array.<index> = { data: merged data , to: recipient  }
		//TODO: make map
		
		//SIMPL: Object.{ data: merged data , to: recipient  }
		private var catchedData:Object;
		private var catchedRecipient:uint;
		
		private var _mode:uint = ChainMode.ONLY_LAST;
		private var _chain:Chain = Chain.initByMode(_mode);
		
		//------------ constructor ------------//
		
		public function ChainTrait(type:String)
		{
			super(type,true);
			
			//sendTimer.start();
			sendTimer.addEventListener(TimerEvent.TIMER, sendTimerTickHandler);
		}
		
		//------------ initialize ------------//
		
		//--------------- ctrl ---------------//
		
		// if we do not want to send data to service, then we need to return null.
		override protected function prepareOutputData(data:Object):Object
		{
			if(true)//catchedData === data)
			{
				catchedData = null;
				return data;
			}
			else
			{
				catchedData = data;
				
				return null;
			}
		}
		
		private function switchMode(from:uint, to:uint):void
		{
			
			_mode = from;
		}
		
		//------------ get / set -------------//
		
		/**
		 * @see ru.teachbase.traits.ChainMode
		 */
		public function get mode():uint
		{
			return _mode;
		}
		
		/**
		 * @private
		 */
		public function set mode(value:uint):void
		{
			if(_mode === value)
				return;
			
			switchMode(_mode, value);
		}
		
		public function get delay():Number
		{
			return sendTimer.delay;
		}
		
		public function set delay(value:Number):void
		{
			sendTimer.delay = value;
		}
		
		//------- handlers / callbacks -------//
		
		private function sendTimerTickHandler(e:TimerEvent):void
		{
			catchedData && output(catchedData, catchedRecipient);
		}
	}
}