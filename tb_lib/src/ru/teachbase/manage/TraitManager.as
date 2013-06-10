package ru.teachbase.manage
{
import flash.errors.IllegalOperationError;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.IEventDispatcher;
import flash.utils.Dictionary;

import mx.rpc.IResponder;

import ru.teachbase.events.TraitEvent;
import ru.teachbase.model.Packet;
import ru.teachbase.net.Service;
import ru.teachbase.traits.Trait;

public class TraitManager extends EventDispatcher implements IEventDispatcher
	{
		public static const instance:TraitManager = new TraitManager();
		
			
		// links:
		private var service:Service;
		
		private const traits:Dictionary = new Dictionary(true);
		
		
		//------------ constructor ------------//
		
		public function TraitManager()
		{
			super(this);
			if(instance)
				throw new IllegalOperationError(TraitManager + ' is an implementation of Singleton pattern. Use TraitManager.instance property.');
		}
		
		//------------ initialize ------------//
		
		__manage function registerService(service:Service):void
		{
			this.service = service;
		}
		
		//--------------- private ---------------//
		
		
		//--------------- API ---------------//
		
		
		/**
		 * Create a new trait of class <i>clazz</i> or return an existing one. 
		 *  
		 * @param clazz
		 * @share set to <i>false</i> if you want to create a new private trait
		 * @return 
		 * 
		 */		
		
		public function createTrait(clazz:Class, share:Boolean = true,...args):Trait{
			if(!share)
				return new clazz(args) as Trait;
			
			if(!traits[clazz]){
				if(args.length)
					traits[clazz] = new clazz(args);
				else
					traits[clazz] = new clazz();
			}
			
			return traits[clazz];
			
		}
		
		
		
		
		
		/**
		 * Using for push and adapt messages received by the service to module-instances
		 */		
				
		public function inputCall(method:String, ...rest:Array):void
		{
			const p:Packet = rest[0];
			const e:TraitEvent = new TraitEvent(p.type, p, this, true);
			dispatchEvent(e);
		}
		
		/**
		 * Using for adapt and push messages received by module-instances to the service and then to server.
		 */		

		public function output(type:String, data:Object, recipient:*, mid:uint = 0,system:Boolean = true):void
		{
			const p:Packet = new Packet(type, data, recipient, mid, system);
			service.output(p);
		}
		
		
		/**
		 * Use to invoke server method and get result
		 * 
		 */
		
		public function call(method:String, responder:IResponder, data:Array):void{
			service.outputCall(method, responder, data);
			return;
		}
		
		//--------------- ctrl ---------------//
		
		override public function dispatchEvent(e:Event):Boolean
		{
			if(!(e is TraitEvent))
			{
				throw new ArgumentError(TraitManager + '.dispatchEvent: Invalid argument is received by this function. It must be or extend TraitEvent class.');
				return false;
			}
			return super.dispatchEvent(e);
		}
		
		//------------ get / set -------------//
		
		//------- handlers / callbacks -------//
	}
}