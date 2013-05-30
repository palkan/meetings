package ru.teachbase.features.live.mouse
{

import flash.display.Sprite;
import flash.events.MouseEvent;

import ru.teachbase.core.App;
import ru.teachbase.events.ChangeEvent;
import ru.teachbase.model.Packet;
import ru.teachbase.model.constants.Recipients;
import ru.teachbase.module.board.BoardCanvas;

/**
	 * @author webils (created: May 14, 2012)
	 */
	public final class LiveCursorManager
	{
		
		
		private static const FIXED_WIDTH:int = 400;
		
		private var _display:Sprite;
		private var  trait:LiveCursorTrait;
		private var _share:Boolean;
		private var _id:int;
		public var showMe:Boolean = true;
		private var container:BoardCanvas;
		
		// .<userID> = Cursor
		private const cursors:Object = new Object();
		
		//------------ constructor ------------//
		
		public function LiveCursorManager(cont:BoardCanvas, id:int = 0)
		{
			_id = id;
			container = cont;
			
			trait = new LiveCursorTrait(id);
			
			trait.addEventListener(ChangeEvent.CHANGED,traitInputHandler);
		}
		
				
		//--------------- ctrl ---------------//
		
		private function enableSharing():void
		{
			//_display.mouseEnabled = true;
			container.addEventListener(MouseEvent.CLICK, userInputHandler);
		}
		
		private function disableSharing():void
		{
		//	_display.mouseEnabled = false;
			container.removeEventListener(MouseEvent.CLICK, userInputHandler);
			
			var result:LiveCursor = cursors[App.room.user.sid];
			
			if(result){
				result.deactivate();
				trait.output({remove:true}, showMe ? Recipients.ALL : Recipients.ALL_EXCLUDE_ME);
			}
			
		}
		
		
		private function getOrCreateCursor(userID:Number):LiveCursor
		{
			var result:LiveCursor = cursors[userID];
			
			if(!result)
			{
				result = cursors[userID] = new LiveCursor(userID);
				display.addChild(result);
			}
			
			return result;
		}
		
		//------------ get / set -------------//
		
		public function get share():Boolean
		{
			return _share;
		}
		
		public function set share(value:Boolean):void
		{
			if(_share === value)
				return;
			
			_share = value;
			
			value ? enableSharing() : disableSharing();
		}
		
		//------- handlers / callbacks -------//
		
		
		private function userInputHandler(e:MouseEvent):void
		{
			var _canvasWidth:Number = container.formatBounds.width;
			var _k:Number = FIXED_WIDTH / _canvasWidth;
			
			trait.output({x: container.mouseX * _k, y: container.mouseY * _k}, showMe ? Recipients.ALL : Recipients.ALL_EXCLUDE_ME);
		}
		
		private function traitInputHandler(e:ChangeEvent):void
		{
			
			const p:Packet = e.value as Packet;
			
			const cursor:LiveCursor = getOrCreateCursor(p.from);
			
			
			if(p.data.remove){
				cursor.deactivate();
				return;
			}
			
			
			var _k:Number = container.formatBounds.width / FIXED_WIDTH;
			
			cursor.move(_k * p.data.x, _k * p.data.y);
			
			const active:Array = new Array();
			for each(var c:LiveCursor in cursors)
			{
				if(c.active)
					active.push(c);
			}
			
			const showLabels:Boolean = active.length > 1;
			
			for each(var a:LiveCursor in active)
				a.showLabel = showLabels;
		}

		public function get display():Sprite
		{
			return _display;
		}

		public function set display(value:Sprite):void
		{
			_display = value;
			
			if(!value)
				return;
			
			with(_display)
			{
				mouseEnabled = mouseChildren = buttonMode = useHandCursor = false;
			}

			
		}

	}
}