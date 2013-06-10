package ru.teachbase.utils.chain
{
import flash.events.Event;
import flash.events.IEventDispatcher;
import flash.events.TimerEvent;
import flash.utils.Timer;

/**
	 * Base simple chain for any objects.
	 * Implements: <code> 0 SOFFA 00 </code>
	 * @author Teachbase (created: May 18, 2012)
	 */
	public class Chain
	{
		protected var data:Object;
		private var _mode:uint = 0;
		
		private var _storage:Array = new Array();
		
		private var _merge:Function;
		
		private const sendTimer:Timer = new Timer(150);
		
		private var _exec:Function;
		
		private var _host:IEventDispatcher;
		
		//------------ constructor ------------//
		
		public function Chain(mode:uint)
		{
			_mode = mode;
		}
		
		//------------ initialize ------------//
		
		public static function initByMode(mode:uint):Chain
		{
			
			return new Chain(mode);
		}
		
		/**
		 * Set merge function for merge mode
		 *  
		 * @param f function with 2 arguments (oldData,newData)
		 * 
		 */
		public function setMergeFuntion(f:Function):void{
			_merge = f;
		}
		
		
		//--------------- ctrl ---------------//
		
		public function push(data:Object):void
		{
			switch(_mode){
				case ChainMode.SAVING:
				case ChainMode.ALL:
				case ChainMode.FIRST_MIDDLE_LAST:
					_storage.push(data);
				break;
				case ChainMode.MERGE_TO_NEXT:
					merge(data);
				break;
				case ChainMode.ONLY_LAST:
					_storage.pop();
					_storage.push(data);
				break;
			}
		}
		
		
		private function merge(newData:Object):void{
			
			if(_storage.length === 0){
				_storage.push(newData);
				return;
			}
			
			var oldData:Object = _storage.pop();
			
			_merge && _storage.push(_merge(oldData,newData));
			
		}
		
		
		/**
		 * Start timer to dispatch events
		 *  
		 * @param host event dispatcher
		 * @param delayTime delay time (>100 ms)
		 * 
		 */
		public function startDispatchTimer(host:IEventDispatcher,delayTime:int = 0):void{
			(delayTime > 100) && (sendTimer.delay = delayTime);
			
			if(host){
				_host = host;
			
				sendTimer.addEventListener(TimerEvent.TIMER,onDispatchTimer);
			
				sendTimer.start();
			}
		}
		
		
		public function stopDispatchTimer():void{
			
			sendTimer.removeEventListener(TimerEvent.TIMER,onDispatchTimer);
			sendTimer.stop();
			
			onDispatchTimer();
		}
		
		
		protected function onDispatchTimer(event:TimerEvent = null):void
		{
			
			if(_storage.length === 0)
				return;
			
			var _e:Event = _storage.pop() as Event;
			
			_host.dispatchEvent(_e);
			
		}		
				
		protected function switchMode(from:uint, to:uint):void
		{
			// processing
			
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
		
		//------- handlers / callbacks -------//
		
	}
}