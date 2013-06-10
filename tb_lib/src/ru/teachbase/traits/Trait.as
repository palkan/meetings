package ru.teachbase.traits
{
import flash.errors.IllegalOperationError;
import flash.events.EventDispatcher;

import mx.core.EventPriority;
import mx.rpc.IResponder;

import ru.teachbase.events.TraitEvent;
import ru.teachbase.manage.TraitManager;
import ru.teachbase.model.constants.Recipients;

public class Trait extends EventDispatcher
	{
		private var _type:String;
		private var _initialized:Boolean;
		protected var _instanceId:uint;
		
		private const _messagesToDo:Array = new Array();
		protected var _readyToReceive:Boolean = false;
		
		//------------ constructor ------------//
		
		public function Trait(type:String, initialize:Boolean = false)
		{
			_type = type;
			initialize && this.initialize();
		}
		
		//------------ initialize ------------//
		
		public function initialize(...rest):void
		{
			if(_initialized) return;
		
			dispatcher.addEventListener(_type,inputHandler,false,EventPriority.BINDING);
			
			_initialized = true;
		}
		
		public function dispose():void
		{
			dispatcher.removeEventListener(_type, inputHandler);
		}
		
		//--------------- ctrl ---------------//
		
		public final function output(data:Object, recipient:* = Recipients.ALL, responder:IResponder = null,system:Boolean = true):void
		{
			const preparedData:Object = prepareOutputData(data);
			
			preparedData && sendOutputData(preparedData, recipient, system);
			
		}
		
		/**
		 * call(CallMethod.getHistory,,,,)
		 * 
		 * @param method - method name
		 * @param responder
		 * @param data - any arguments
		 * 
		 * @see ru.teachbase.model.CallMethod
		 */		
		public final function call(method:String, responder:IResponder = null, ...data:Array):void
		{
			dispatcher.call(method, responder, data);
		}
		
		protected function prepareOutputData(data:Object):Object
		{
			// Base method
			
			// In the any subclass if we do not want to send data to service, then we need to return null.
			
			return data;
		}
		
		protected function sendOutputData(data:Object, recipient:*, system:Boolean):void
		{
			if(data == null)
			{
				throw IllegalOperationError(this + "data must not be null!");
			}

			dispatcher.output(_type, data, recipient, _instanceId, system);
		}
		
		/**
		 * Using for processing and adapt data received by the dispatcher <- service
		 * <br/>
		 */		
		protected function prepareInput(data:Object):Object
		{
			// Base method
			
			// In the any subclass if we do not want to send data to service, then we need to return null.
			
			return data;
		}
		
		
		
		protected function dispatchTraitEvent(data:Object):void{
			
			// Base method
			
			throw IllegalOperationError(this + "you have to override this method!");
			
		}
		
		
			
		//------------ get / set -------------//
		
		public static function get dispatcher():TraitManager
		{
			return TraitManager.instance;
		}
		
		public function get type():String
		{
			return _type;
		}
		
		public function get initialized():Boolean
		{
			return _initialized;
		}
		
		//------- handlers / callbacks -------//
		
		private final function inputHandler(e:TraitEvent):void
		{
			
			const data:Object = prepareInput(e.packet);
			
			if(data is int || data is uint || data is Number || data){
				_readyToReceive && dispatchTraitEvent(data);
				!_readyToReceive && _messagesToDo.push(data);
			}
			
		}

		public function set readyToReceive(value:Boolean):void
		{
			if(_readyToReceive)
				return;
			_readyToReceive = value;
			
			for each (var _d:* in _messagesToDo)
				dispatchTraitEvent(_d);
			
			_messagesToDo.length = 0;
			
		}
		
		
		
		
		
	}
}