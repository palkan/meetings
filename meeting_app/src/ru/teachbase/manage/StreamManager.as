package ru.teachbase.manage
{
import flash.events.AsyncErrorEvent;
import flash.events.ErrorEvent;
import flash.events.IOErrorEvent;
import flash.events.NetStatusEvent;
import flash.net.NetStream;
import flash.utils.Dictionary;

import mx.core.EventPriority;
import mx.rpc.Responder;

import ru.teachbase.core.App;
import ru.teachbase.events.ChangeEvent;
import ru.teachbase.events.GlobalEvent;
import ru.teachbase.events.StreamEvent;
import ru.teachbase.events.TraitEvent;
import ru.teachbase.model.LocalStream;
import ru.teachbase.model.Packet;
import ru.teachbase.model.Stream;
import ru.teachbase.model.User;
import ru.teachbase.model.constants.PacketType;
import ru.teachbase.model.constants.RecordingStates;
import ru.teachbase.traits.StreamStateTrait;
import ru.teachbase.traits.StreamTrait;
import ru.teachbase.utils.Logger;
import ru.teachbase.utils.Permissions;

CONFIG::RECORDING{
    import ru.teachbase.utils.helpers.registerStreamRec;
}
	
	/**
	 * @author Webils (created: Mar 2, 2012)
	 */
	
	public dynamic class StreamManager extends Manager
	{
		private const RESTART_STREAM_TIME:int = 2000;
		
		public const trait:StreamTrait = TraitManager.instance.createTrait(StreamTrait) as StreamTrait;
		public const _s_trait:StreamStateTrait = TraitManager.instance.createTrait(StreamStateTrait) as StreamStateTrait;
		
		private var _enabled:Boolean = true;
		
		private var streams:Dictionary = new Dictionary(true);
		private var streamsByUid:Object = {};
				
		//------------ constructor ------------//
		
		public function StreamManager()
		{
			super();
			new Stream();
			trait.call("get_history", new Responder(onHistoryRecieved, null), "video");
		}
		
		//------------ initialize ------------//
		
		override protected function initialize():void
		{

			trait.addEventListener(StreamEvent.STREAM, traitInputHandler);
			trait.addEventListener(StreamEvent.STREAM_CHANGE, streamChangeHandler);
			_s_trait.addEventListener(ChangeEvent.CHANGED, onStreamStatusChanged);
			
			GlobalEvent.addEventListener(GlobalEvent.USER_LEAVE,onUserLeave);
						
			_initialized = true;
		}
		
		
		private function onStreamStatusChanged(e:ChangeEvent):void{
			
			switch(e.value){
				
				case "disconnect":
					removeLocalStreams();
					_enabled = false;
					break;
				case "connect":
					_enabled = true;
					trait.call("get_history", new Responder(onHistoryRecieved, null), "video");
					break;
			}
			
		}
		
		
		protected function streamChangeHandler(event:StreamEvent):void
		{
			
			if(!event.stream || !_enabled) 
				return;
			
			if(streamsByUid[event.stream.userId] && App.room.usersByID[event.stream.userId]){
				if((App.room.usersByID[event.stream.userId] as User).shareStatus & Permissions.CAMERA){
					addVideoStream(streamsByUid[event.stream.userId]);				
				}else if((App.room.usersByID[event.stream.userId] as User).shareStatus & Permissions.MIC){
					var _str:LocalStream = new LocalStream(null,event.stream.userId);
					addVideoStream(_str);
				}else{
					removeLocalStream(event.stream.userId);
				}
			}
		}
		
		
		
		protected function onUserLeave(event:GlobalEvent):void{
			removeLocalStream(event.value.sid);
		}
		
		//--------------- ctrl ---------------//
		
		private function addStream(stream:Stream):LocalStream
		{
			if(streamsByUid[stream.userId])
				return streamsByUid[stream.userId];

			var ns:NetStream = new NetStream(App.service.media_connection);

			ns.addEventListener(NetStatusEvent.NET_STATUS, streamPlayOnStatusHandler,false,EventPriority.DEFAULT_HANDLER);
			var ns_client:Object = {};
			ns_client.onMetaData = function(metadata:Object):void {};
			ns.client = ns_client;
			

			ns.addEventListener(AsyncErrorEvent.ASYNC_ERROR, streamErrorHandler);
			ns.addEventListener(IOErrorEvent.IO_ERROR, streamErrorHandler);
			

			var localStream:LocalStream = new LocalStream(ns, stream.userId);
			localStream.name = stream.name;
			localStream.active = true;
			localStream.rotation = stream.rotation;
			streams[ns] = localStream;
			streamsByUid[stream.userId] = localStream;
			
CONFIG::RECORDING
				{
			ns.bufferTime = 2;
			registerStreamRec(localStream,stream.name);
			if(App.room.recordModel.state === RecordingStates.PLAYING) ns.play(stream.name);
			
				}
			
CONFIG::LIVE 
			{
			ns.bufferTime = 0;
			ns.backBufferTime = 0;
			ns.play(stream.name);
			}

			return localStream; 
		}

		
		private function traitInputHandler(e:StreamEvent):void
		{
			dispatchStream(e.stream);			
		}
		
		private function getLocalStream(stream:NetStream):LocalStream{
			if (!stream || !(stream is NetStream) || !streams[stream])
				return null;
			
			return streams[stream];
			
		}
		
		
		private function removeLocalStream(uid:Number):void{
			if (!streamsByUid[uid])
				return;
			
			var localStream:LocalStream = streamsByUid[uid];
			delete streams[localStream.stream];
			localStream.stream.close();
			localStream.stream = null;
			addVideoStream(localStream);
			delete streamsByUid[localStream.userId];
		}
		
		
		
		private function removeLocalStreams():void{
			for each (var localStream:LocalStream in streams) {
					delete streams[localStream.stream];
					localStream.stream = null;
					addVideoStream(localStream);
					delete streamsByUid[localStream.userId];
			}
		}
		
		
		private function addVideoStream(str:LocalStream):void{
			TraitManager.instance.dispatchEvent(new TraitEvent(PacketType.I_VIDEO, new Packet(PacketType.I_VIDEO,str)));	
		}
		
		private function dispatchStream(str:Stream):void{
			if(!App.room.usersByID[str.userId]) return;
			const localStream:LocalStream = addStream(str);
			((App.room.usersByID[str.userId] as User).shareStatus & Permissions.CAMERA) && addVideoStream(localStream);
		}
		
		private function streamErrorHandler(e:ErrorEvent):void
		{
			throw e;
		}
		
		private function streamPlayOnStatusHandler(e:NetStatusEvent):void
		{

			Logger.log(e.info.code,'stream');
			
			if (!(e.target as NetStream)) return;
			
			switch(e.info.code){
				case('NetConnection.Connect.Closed'):
				case('NetStream.Connect.Closed'):
				case('NetStream.Play.Failed'):
				case('NetStream.Play.Stop'):
				case "NetStream.Play.StreamNotFound":
				{
					var _ls:LocalStream = streams[e.target] as LocalStream;
					
					if(!_ls) return;
					
					checkFailedStream(_ls);
					
					break;
				}
				case "NetStream.Play.Start":
					
					//(streams[e.target] as LocalStream).active = true;
					
					break;
				case "NetStream.Video.DimensionChange":
				{

					break;
				}
					

			}
		}
		
		
		private function checkFailedStream(ls:LocalStream):void{
			
			trait.call('stream_exists',new Responder(success,null),ls.userId); 
			
			function success(flag:Boolean):void{
				
				if(flag)
					restartStream(ls.stream);
				else
					removeLocalStream(ls.userId);
			}
			
		}
		
		
		private function restartStream(stream:NetStream):void{
			
			if(streams[stream]){
				var _ls:LocalStream = streams[stream];
				
				var _name:String = _ls.name;
				var _id:Number = _ls.userId;
				
				removeLocalStream(_id);
				
				addStream(new Stream(_name,_id));
			}
			
		}
		
		public function closeUserStream(uid:Number):void{
			trait.call("close_stream",null,uid);
		}
		
		
		private function onHistoryRecieved(v:Array):void{
			if (v && v.length) {
				for each (var str:Stream in v) {
					dispatchStream(str)
				}
			}
			
			trait.readyToReceive = true;
		}
		
		
		public function get videoStreams():Array{
			var response:Array = [];
			for each(var str:LocalStream in streams){
				App.room.usersByID[str.userId] && ((App.room.usersByID[str.userId] as User).shareStatus & Permissions.CAMERA) && response.push(str);
			}
			
			return response;
		}
		
		
		override public function dispose():void{
			_initialized = false;
		}
	}
}
