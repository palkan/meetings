package ru.teachbase.net
{
import flash.errors.IllegalOperationError;
import flash.utils.Dictionary;
import flash.utils.Proxy;
import flash.utils.flash_proxy;

use namespace flash_proxy;
	
	/**
	 * @author Teachbase (created: May 11, 2012)
	 */
	public dynamic class ClientProxy extends Proxy 
	{
		private const storage:Dictionary = new Dictionary(true);
		private var service:IService;
		
		//------------ constructor ------------//
		
		public function ClientProxy(host:IService)
		{
			service = host;
		}
		
		//------------ initialize ------------//
		
		//--------------- ctrl ---------------//
		
		override flash_proxy function callProperty(name:*, ...parameters):*
		{
			parameters.unshift(name);
			return service.incomingCall.apply(null, parameters);
		}
		
		override flash_proxy function deleteProperty(name:*):Boolean
		{
			if(!storage.hasOwnProperty(name))
				return false;
			
			const value:* = storage[name];
			
			delete storage[name];
			
			return true;
		}
		
		override flash_proxy function setProperty(name:*, value:*):void
		{
			storage[name] = value;
		}
		
		
		
		override flash_proxy function getProperty(name:*):*
		{
			const nameStr:String = String(name);
			
			if(!storage.hasOwnProperty(name) && nameStr.indexOf('on') === 0 && nameStr.length > 2)
			{
				const proxyClosure:Object = function (...rest:Array):*
				{
					rest.unshift(name);
					return service.incomingCall.apply(null, rest);
				};
				
				proxyClosure.fname = name;
				storage[name] = proxyClosure;
				return proxyClosure;
			}
			
			return storage[name];
		}
		
		override flash_proxy function hasProperty(name:*):Boolean
		{
			return storage.hasOwnProperty(name);
		}
		
		
		
		
		override flash_proxy function getDescendants(name:*):*
		{
			throw new IllegalOperationError('this feature is not supported yet');
			return null;
		}
		
		override flash_proxy function nextName(index:int):String
		{
			throw new IllegalOperationError('this feature is not supported yet');
			return super.flash_proxy::nextName(index);
		}
		
		override flash_proxy function nextNameIndex(index:int):int
		{
			throw new IllegalOperationError('this feature is not supported yet');
			return super.flash_proxy::nextNameIndex(index);
		}
		
		override flash_proxy function nextValue(index:int):*
		{
			throw new IllegalOperationError('this feature is not supported yet');
			return super.flash_proxy::nextValue(index);
		}
		
		//------------ get / set -------------//
		
		//------- handlers / callbacks -------//
		
	}
}