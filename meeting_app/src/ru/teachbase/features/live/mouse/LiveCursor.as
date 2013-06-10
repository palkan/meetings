package ru.teachbase.features.live.mouse
{
import caurina.transitions.Tweener;

import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.events.TimerEvent;
import flash.filters.DropShadowFilter;
import flash.filters.GlowFilter;
import flash.geom.ColorTransform;
import flash.geom.Point;
import flash.text.AntiAliasType;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.utils.Timer;

import ru.teachbase.model.App;

import ru.teachbase.utils.shortcuts.style;

/**
	 * @author Aleksandr Kozlovskij (created: May 15, 2012)
	 */
	internal final class LiveCursor extends Sprite
	{
		private const position:Point = new Point(NaN, NaN);
		
		private var _showLabel:Boolean;
		private var _label:String;
		private var _field:TextField;
		
		private var _id:Number;
		
		private var _icon:DisplayObject;
		
		private const activity:Timer = new Timer(2000, 1);
		
		//------------ constructor ------------//
		private var color:Number;
		
		public function LiveCursor(id:Number)
		{
			super();
			
			_id = id;
			
			color = 0xFFFFFF * Math.random();
			
			_icon = style("wb","pointerBig");
			
			const ctr:ColorTransform = new ColorTransform();
			ctr.color = color;
			
//			_icon.transform.colorTransform = ctr;
			_icon.filters = [new DropShadowFilter(3, 45, 0, .4, 3, 3), new GlowFilter(0x00A2FF,1,10,10,2,1,true)];
			addChild(_icon);
			
		/*	graphics.beginFill();
			graphics.lineStyle(0, 0x0);
			graphics.drawRect(0, 0, 10, 10);
			graphics.endFill();*/
			
			field.text = App.meeting.usersByID[_id] ? App.meeting.usersByID[_id].fullName : "";
			
		//	activity.addEventListener(TimerEvent.TIMER_COMPLETE, deactivatePrepareHandler);
		}
		
		//------------ initialize ------------//
		
		private function createField():TextField
		{
			_field = new TextField();
			_field.multiline = false;
			_field.selectable = false;
			_field.mouseEnabled = false;
			_field.autoSize = TextFieldAutoSize.LEFT;
			_field.antiAliasType = AntiAliasType.ADVANCED;
			
			_field.background = true;
			//_field.backgroundColor = 0xFFCCFF;
			
			_field.background = true;
			//_field.backgroundColor = color;
			_field.backgroundColor = 0xFFFFFF;
			_field.border = true;
			_field.borderColor = 0x0;
			
			_field.x = 10;
			
			return _field;
		}
		
		//--------------- ctrl ---------------//
		
		public function move(x:int, y:int/*, time:Number*/):void
		{
			if(isNaN(position.x) && isNaN(position.y))
			{
				this.x = x;
				this.y = y;
			}
			else
				Tweener.addTween(this, {x:x, y:y, time:.4});
			
			position.x = x;
			position.y = y;
			
			activate();
		}
		
		public function activate():void
		{
			activity.reset();
			activity.start();
			
			Tweener.addTween(this, {alpha:1, time:.2});
		}
		
		public function deactivate():void
		{
			activity.reset();
			
			Tweener.addTween(this, {alpha:0, time:.2});
		}
		
		private function addLabel():void
		{
			if(!contains(field))
				field.alpha = 0;
			
			addChild(field);
			Tweener.addTween(field, {alpha:1, time:.2});
		}
		
		private function remLabel():void
		{
			contains(field) && removeChild(field);
			Tweener.addTween(field, {alpha:0, time:.2});
		}
		
		//------------ get / set -------------//
		
		public function get showLabel():Boolean
		{
			return _showLabel;
		}
		
		public function set showLabel(value:Boolean):void
		{
			if(_showLabel === value)
				return;
			
			_showLabel = value;
			
			value ? addLabel() : remLabel();
		}
		
		public function get label():String
		{
			return _label || _id.toString();
		}
		
		public function set label(value:String):void
		{
			if(_label === value)
				return;
			
			_label = value;
		}
		
		public function get field():TextField
		{
			return _field || createField();
		}
		
		public function get id():int
		{
			return _id;
		}
		
		public function get active():Boolean
		{
			return activity.running;
		}
		
		
		//------- handlers / callbacks -------//
		
		private function deactivatePrepareHandler(e:TimerEvent):void
		{
			deactivate();
		}
	}
}