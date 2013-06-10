package ru.teachbase.net.factory
{


import flash.errors.IOError;
import flash.events.AsyncErrorEvent;
import flash.events.EventDispatcher;
import flash.events.NetStatusEvent;
import flash.events.SecurityErrorEvent;
import flash.events.TimerEvent;
import flash.net.NetConnection;
import flash.utils.Timer;

import ru.teachbase.utils.Logger;

[Event(name="connectionCreated", type="ru.teachbase.net.factory.ConnectionFactoryEvent")]
	
	[Event(name="connectionError", type="ru.teachbase.net.factory.ConnectionFactoryEvent")]
	
	[Event(name="connectionTimeout", type="ru.teachbase.net.factory.ConnectionFactoryEvent")]
	
	internal class NetConnectionNegotiator extends EventDispatcher
	{
		
		private static const DEFAULT_TIMEOUT:Number = 200000;
		private static const CONNECTION_ATTEMPT_INTERVAL:Number = 50;
		
		private var host:String;
		private var path:String;
		
		private var pnp:Array;
		private var timeOutTimer:Timer;
		private var connectionTimer:Timer;
		private var failedConnectionCount:int;
		private var attemptIndex:int;
		
		private var netConnections:Vector.<NetConnection> = new Vector.<NetConnection>();
		
		
		public function NetConnectionNegotiator():void
		{
			super();
		}
		
		
		public function createNetConnection(host:String, path:String, portsAndProtocols:String):void
		{
			this.host = host;
			this.path = path;
			
			pnp = new Array();
			
			for each(var str:String in portsAndProtocols.split(","))
				pnp.push(str.split(":"));
				
			
			initializeConnectionAttempts();
			tryToConnect(null);
		}
		
		
		private function initializeConnectionAttempts():void
		{
			// Master timeout
			timeOutTimer = new Timer(DEFAULT_TIMEOUT, 1);
			timeOutTimer.addEventListener(TimerEvent.TIMER_COMPLETE, masterTimeout);
			timeOutTimer.start();
			
			// Individual attempt sequencer
		/*	connectionTimer = new Timer(CONNECTION_ATTEMPT_INTERVAL);
			connectionTimer.addEventListener(TimerEvent.TIMER, tryToConnect);
			connectionTimer.start();
			*/
			// Initialize counters
			failedConnectionCount = 0;
			attemptIndex = 0;
		}
		
		
		private function tryToConnect(evt:TimerEvent):void 
		{
			var _nc:NetConnection = new NetConnection();
			_nc.addEventListener(NetStatusEvent.NET_STATUS, onNetStatus, false, 0, true);
			_nc.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onNetSecurityError, false, 0, true);
			_nc.addEventListener(AsyncErrorEvent.ASYNC_ERROR, onAsyncError, false, 0, true);
			netConnections.push(_nc);
			try 
			{
				
				_nc.connect(pnp[attemptIndex][0]+"://"+host+":"+pnp[attemptIndex][1]+path);
		
				attemptIndex++;
				/*if (attemptIndex >= pnp.length) 
				{
					connectionTimer.stop();
				}*/
			}
			catch (ioError:IOError) 
			{
				Logger.log("IOError: Unable to connect through "+pnp[attemptIndex-1][0]+":"+pnp[attemptIndex-1][1],"Connection");
				handleFailed();
			}
			catch (argumentError:ArgumentError) 
			{
				Logger.log("ArgumentError: Unable to connect through "+pnp[attemptIndex-1][0]+":"+pnp[attemptIndex-1][1],"Connection");
				handleFailed();
			}
			catch (securityError:SecurityError) 
			{
				Logger.log("SecurityError: Unable to connect through "+pnp[attemptIndex-1][0]+":"+pnp[attemptIndex-1][1],"Connection");
				handleFailed();
			}
		}
		
		
		private function onNetStatus(event:NetStatusEvent):void 
		{
			switch (event.info.code) 
			{
				case "NetConnection.Connect.Closed":
				case "NetConnection.Connect.Failed":
				case "NetConnection.Connect.Rejected":
					handleFailed();
					break;
				case "NetConnection.Connect.Success":
					shutDownUnsuccessfulConnections();
					dispatchEvent(new ConnectionFactoryEvent(ConnectionFactoryEvent.CREATED,event.target as NetConnection));
					break;
			}
		}
		
		
		private function shutDownUnsuccessfulConnections():void
		{
			timeOutTimer.stop();
			//connectionTimer.stop();
			for (var i:int = 0; i < netConnections.length; i++) 
			{
				var nc:NetConnection = netConnections[i];
				nc.removeEventListener(NetStatusEvent.NET_STATUS, onNetStatus);
				nc.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onNetSecurityError);
				nc.removeEventListener(AsyncErrorEvent.ASYNC_ERROR, onAsyncError);
				if (!nc.connected)
				{
					nc.close();
					delete netConnections[i];
				}
			}
		}
		
		private function handleFailed():void{
			
			failedConnectionCount++;
			if (failedConnectionCount >= pnp.length) 
			{
				dispatchEvent(new ConnectionFactoryEvent(ConnectionFactoryEvent.CONNECT_ERROR));					
			}else{
				tryToConnect(null);
			}
		}
		
		private function onNetSecurityError(event:SecurityErrorEvent):void
		{
			Logger.log("SecurityErrorEvent:  "+event.target,"Connection");
		}
		
		
		private function onAsyncError(event:AsyncErrorEvent):void 
		{
			Logger.log("AsyncErrorEvent:  "+event.target,"Connection");
		}
		
		
		private function masterTimeout(event:TimerEvent):void 
		{
			dispatchEvent(new ConnectionFactoryEvent(ConnectionFactoryEvent.CONNECT_TIMEOUT));			
		}
		
	}
}

