package ru.teachbase.module.board.figures
{
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.events.TimerEvent;
import flash.geom.Point;
import flash.utils.Dictionary;
import flash.utils.Timer;

import mx.managers.CursorManager;
import mx.managers.CursorManagerPriority;
import mx.rpc.Responder;

import ru.teachbase.constants.PacketType;
import ru.teachbase.features.live.mouse.LiveCursorManager;
import ru.teachbase.manage.rtmp.RTMPListener;
import ru.teachbase.manage.rtmp.events.RTMPEvent;
import ru.teachbase.manage.rtmp.model.Recipients;
import ru.teachbase.module.board.BoardCanvas;
import ru.teachbase.module.board.components.BoardTextInput;
import ru.teachbase.module.board.instruments.DrawInstrument;
import ru.teachbase.module.board.instruments.Instrument;
import ru.teachbase.module.board.instruments.InstrumentType;
import ru.teachbase.module.board.instruments.TextInstrument;
import ru.teachbase.module.board.style.FillStyle;
import ru.teachbase.module.board.style.StrokeStyle;
import ru.teachbase.skins.cursors.BoardCursor;
import ru.teachbase.utils.helpers.getValue;
import ru.teachbase.utils.shortcuts.rtmp_history;
import ru.teachbase.utils.shortcuts.rtmp_send;
import ru.teachbase.utils.shortcuts.style;

/**
	 * @author Webils (created: Mar 20, 2012)
	 */
	public class FigureManager
	{
		private var _container:BoardCanvas;
		
		private const externals:Vector.<ExternalFigure> = new Vector.<ExternalFigure>();
		private const catchedChanges:Dictionary = new Dictionary(false);
		
		[Bindable]
		public var history:BoardHistory;
		
		
		private var _currentInstrument:Instrument;
		
		private const listener:RTMPListener = new RTMPListener(PacketType.WHITEBOARD);
		
		private const sendTimer:Timer = new Timer(800);
		
		private var _cursorManager:LiveCursorManager;
		
		private var _instanceId:int;
		
		
		//------------ constructor ------------//
		
		public function FigureManager()
		{
			
			history =  new BoardHistory(this);
		}
		
		//------------ initialize ------------//
		
		public function initialize(container:BoardCanvas, id:int):void
		{
			
			_container = container;
			_container.manager = this;
			_instanceId = id;
			

			listener.addEventListener(RTMPEvent.DATA, handleMessage);
			
			rtmp_history(PacketType.WHITEBOARD+"::"+id,new Responder(receiveHistory,null));
			
			_cursorManager = new LiveCursorManager(_container, id);
			
			_cursorManager.display = _container.cursorContainer;

		}
		
		
		
		public function dispose():void{
			
			externals.length = 0;
			history.dispose();
			
		}
		
		
		
		protected function handleMessage(e:RTMPEvent):void
		{
			receiveChanges(e.packet.data as Array);
		}
		
		//--------------- ctrl ---------------//
		
		/**
		 * 
		 * @param position:Point initial position of new figure
		 * @param draw:Function must be link to function:<br/>
		 * <code>
		 * function draw(firstPointIndex:int = 0, length:int = int.MAX_VALUE):void
		 * </code>
		 * @return new figure
		 * @see Figure.Figure()
		 */		
		public function createFigure(position:Point, draw:Function, instrument:Instrument, __id:String = null, page:int = -1, stroke:int = -1, color:int = -1, fill:int = -1):IFigure
		{
			const figure:Figure = new Figure(draw, instrument.tid, _container.formatBounds.width);
			figure.x = position.x;
			figure.y = position.y;
			
			
			// make clone from user-style:
			var _stroke:StrokeStyle = container.stroke.clone() as StrokeStyle;
			
			
			if(stroke>0)
				_stroke.thickness = stroke;
			
			if(color > 0)
				_stroke.color = color; 
			
			var _fill:FillStyle = container.fill.clone() as FillStyle;
			
			if(fill > 0)
				_fill.color = fill;
			
			
			figure.thickness = _stroke.thickness;
			figure.color = _stroke.color;
			figure.fillColor = _fill.color;
												
			var _cont:Sprite;
			
			
			if(page>=0){
				_cont = _container.getPageSprite(page).figureContainer;
				figure.page_id = _container.page.pageId;
			}else{
				_cont = _container.page.figureContainer;
				figure.page_id = _container.page.pageId;
			}
			
			_cont.addChild(figure);
			
			// externals:
			const external:ExternalFigure = new ExternalFigure(this, figure, __id);
			externals.push(external);
			external.ignorLocalChanges = !!__id;
			
			history.push({type:"add",id:figure.external.id});
			
			return figure;
		}
		
		
		public function createSharedCursor():void{
			_cursorManager.share = true;
		}
		
		
		public function removeSharedCursor():void{
			_cursorManager.share = false;
			//_cursorManager.dispose();
		}
		
		
		public function createText(position:Point,  __id:String = null, page:int = -1, color:int = -1):IFigure
		{
			const figure:Figure = new Figure(null, InstrumentType.TEXT, TextInstrument.FIXED_WIDTH);
			figure.x = position.x;
			figure.y = position.y;
			
			figure.scaleRelativeCanvasWidth(_container.formatBounds.width);
			// make clone from user-style:
			var _stroke:StrokeStyle = container.stroke.clone() as StrokeStyle;
			
			
			if(color > 0)
				_stroke.color = color; 
			
			figure.color = _stroke.color;
			
			var _cont:Sprite;
						
			if(page>=0){
				_cont = _container.getPageSprite(page).textContainer;
				figure.page_id = page;
			}else{
				_cont = _container.page.textContainer;
				figure.page_id = _container.page.pageId;
			}
			
			_cont.addChild(figure);
			
			
			var _txt:BoardTextInput = new BoardTextInput(figure);
			
			
			figure.textField = _txt;
			figure.addChild(_txt);
			
			// externals:
			const external:ExternalFigure = new ExternalFigureText(this, figure, __id);
			externals.push(external);
			//external.ignorLocalChanges = !!__id;
			
			history.push({type:"add",id:figure.external.id});
			
			return figure;
		}
		
		
		
		
		
		public function removeFigure(id:String, local:Boolean = true, inHistory:Boolean = true):void{
			
			var _f:Figure = getFigureByID(id) as Figure;
			
			if(_f){
				
				if(_f.instrument === InstrumentType.TEXT)
					_container.page.textContainer.removeChild(_f);
				else
					_container.page.figureContainer.removeChild(_f);
				
				local && figureChanged(_f.external, {remove: true, type:"remove", id:_f.id});
				
				inHistory && history.push({type:"remove",id:_f.external.id});
			}
			
		}
		
		
		private function addFigure(id:String):void{
			
			var _f:Figure = getFigureByID(id) as Figure;
			
			if(_f){
				
				if(_f.instrument === InstrumentType.TEXT)
					_container.page.textContainer.addChild(_f);
				else
					_container.page.figureContainer.addChild(_f);
				
			}
			
		}
		
		
		
		public function completeFigure(figure:IFigure):void
		{
			// optimize
			// add visual draggable points
			figure.complete = true;
			// add transformation functional
			
			//figureChanged(figure.external, {complete:true});
			
		}
		
		
		
		public function completeRemove(id:String):void{
			
			var _f:Figure = getFigureByID(id) as Figure;
			
			if(_f){
				externals.splice(externals.indexOf(_f.external),1);				
			}
			
			
		}
		
		
		
		public function undo(obj:Object, local:Boolean = true):void{
			
			if(!obj)
				return;
			
			if(obj.type === "add")
				removeFigure(obj.id,false,false);
			else if(obj.type === "remove")
				addFigure(obj.id);		
			
			var _f:Figure = getFigureByID(obj.id) as Figure;
			
			_f && local && figureChanged(_f.external, {type:"undo",history:true,id:obj.id});
		}
		
		
		public function redo(obj:Object, local:Boolean = true):void{
			
			if(!obj)
				return;
			
			if(obj.type === "remove")
				removeFigure(obj.id,false,false);
			else if(obj.type === "add")
				addFigure(obj.id);	
			
			var _f:Figure = getFigureByID(obj.id) as Figure;
			
			_f && local && figureChanged(_f.external, {type:"redo",history:true,id:obj.id});

		}
		
		
		
		//-- receiving --//
		
		private function receiveHistory(history_obj:Object):void{
			var changes:Array = getValue(history_obj,"figures",[]);
			receiveChanges(changes);
			
			history.clear();
			
			var _history:Array = getValue(history_obj,"history",[]);
			for each(var _el:Object in _history)
				history.push(_el);
			
			var _pos:int = getValue(history_obj,"position",0);
			while(_pos<0){
				undo(history.undo(),false);
				_pos++;
			}
			
			listener.readyToReceive = true;
		}
		
		public function receiveChanges(changes:Array):void
		{
			
			for(var i:int; i < changes.length; ++i)
			{
				const changed:Object = changes[i];
				const existing:IFigure = getFigureByID(changed.id);
				
				// modify:
				if(existing)
				{
					if(changed.remove)
						removeFigure(changed.id,false);
					else if(changed.history)
						this[changed.type](history[changed.type](),false);
					else
						existing.external.updateProperties(changed);
				}
				// create new:
				else
				{
					var oldInstrument:Instrument = currentInstrument;
					const instrument:Instrument = Instrument.get(changed.instrument, container);
					instrument.initialize(this);
					var fig:IFigure;
					if(instrument is TextInstrument)
						fig = createText(new Point(changed.x, changed.y),changed.id,changed.page,changed.color);
					else
						fig = createFigure(new Point(changed.x, changed.y), instrument.getModifierFunction(), instrument, changed.id, changed.page, changed.stroke, changed.color);
						
					fig.external.updateProperties(changed);
					instrument is DrawInstrument && (instrument as DrawInstrument).doCompleteFigure(fig);
					//fig.complete = true;
					instrument.dispose();
					if(oldInstrument){
						currentInstrument = Instrument.get(oldInstrument.tid, container);
						currentInstrument.initialize(this);
					}else{
						currentInstrument = null;
					}
					
					fig.scaleRelativeCanvasWidth(_container.formatBounds.width);
				}
			}
			
		}
		
		//-- catch --//
		
		private function mergeToCatch(external:ExternalFigure, changes:Object):Object
		{
			const stash:Object = catchedChanges[external];
			
			if(!stash)
				return catchedChanges[external] = changes;
			
			for(var key:* in changes)
				catchedChanges[external][key] = changes[key];
			
			return catchedChanges[external];
		}
		
		/**
		 * Works for all figures
		 */		
		public function scaleRelativeCanvasWidth(value:Number):void
		{
			for each(var external:ExternalFigure in externals)
				external.figure && external.figure.scaleRelativeCanvasWidth(value);
		}
		
		public function getFigureByID(id:String):IFigure
		{
			for each(var external:ExternalFigure in externals)
			{
				if(external.figure && external.figure.id == id)
					return external.figure;
			}
			return null;
		}
		
		
		
		private function setCursor(event:MouseEvent = null):void{
			
			if(!_currentInstrument)
				return;
			
			BoardCursor.icon = style("wb",_currentInstrument.tid+"Cursor");
			
			if(BoardCursor.icon)				
				CursorManager.setCursor(BoardCursor,CursorManagerPriority.HIGH);
			else
				CursorManager.removeAllCursors();
		}
		
		
		
		//------------ get / set -------------//
		
		public function get container():BoardCanvas
		{
			return _container;
		}
		
		//------- handlers / callbacks -------//
		
		internal function figureChanged(external:ExternalFigure, changes:Object):void
		{
			
			//changes = mergeToCatch(external, changes);
			catchedChanges[external] = changes;
			sendTimerTickHandler(null);
		}
		
		private function sendTimerTickHandler(e:TimerEvent):void
		{
		
			// adaptation:
			const changes:Array = new Array();
			for each(changes[changes.length] in catchedChanges); // All catched changes now in changes
			
			if(!changes.length)
				return;
			
			rtmp_send(PacketType.WHITEBOARD, changes,Recipients.ALL_EXCLUDE_ME);
			
			//clean
			for(var key:* in catchedChanges)
				delete catchedChanges[key];
		}

		public function get currentInstrument():Instrument
		{
			return _currentInstrument;
		}

		public function set currentInstrument(value:Instrument):void
		{
			
			if(!value){
				_currentInstrument && _currentInstrument.dispose();
				CursorManager.removeAllCursors();
				_container.removeEventListener(MouseEvent.ROLL_OVER,setCursor);
				_container.removeEventListener(MouseEvent.ROLL_OUT, function(e:MouseEvent):void{ CursorManager.removeAllCursors();});
			}else{
				_container.addEventListener(MouseEvent.ROLL_OVER,setCursor);
				_container.addEventListener(MouseEvent.ROLL_OUT, function(e:MouseEvent):void{ CursorManager.removeAllCursors();});
			}
			
			_currentInstrument = value;
			
			
		}

		
	}
}