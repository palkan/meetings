package ru.teachbase.components.board.model
{
import ru.teachbase.components.board.FigureManager;

public class BoardHistory
	{
		
		public const MEM:uint = 5;
				
		private var _history:Array = new Array();
		private var _currentPosition:int = 0;
		
		private var _manager:FigureManager;
		
		private var _undoAvailable:Boolean;
		
		private var _redoAvailable:Boolean;
		
		public function BoardHistory(m:FigureManager)
		{
			_manager = m;
		}
		
		
		public function dispose():void{
			
			_history.length = 0;
			
			
		}
		
		
		public function push(obj:Object):void{
			
			if(_currentPosition < 0){
				handle_redo();
			}
				
			
			if(_history.length === MEM)
				handle_history(_history.shift());
			
			_history.push(obj);
			
			undoAvailable = true;
			redoAvailable = false;
			
			_currentPosition = 0;
			
		}
		
		
		public function undo():Object{
			
			if(_history.length + _currentPosition <= 0)
				return null;
						
			_currentPosition--;
			
			redoAvailable = true;
			undoAvailable = (_history.length + _currentPosition > 0);
			
			return _history[_history.length + _currentPosition];
			
		}
		
		
		public function redo():Object{
			
			if(_currentPosition == 0)
				return null;
			
			_currentPosition++;
			
			redoAvailable = (_currentPosition < 0);
			undoAvailable = true;
			
			return _history[_history.length + (_currentPosition-1)];
			
						
		}
		
		
		public function clear():void{
			
			_history.length = 0;
			
			_currentPosition = 0;
			
			redoAvailable = false;
			undoAvailable = false;
		}
		
		
		
		private function handle_history(obj:Object,type:String = "remove"):void{
			
			if(obj.type === type){
				
				_manager.completeRemove(obj.id);
				
				
			}
			
		}
		
		
		
		private function handle_redo():void{
			
			var _temp:Array = _history.slice(_history.length + _currentPosition);
			
			for each(var _obj:Object in _temp)
				handle_history(_obj,"add");
			
			
			_history = _history.slice(0,_history.length + _currentPosition);
				
		}
		
		
		
		[Bindable]
		public function get redoAvailable():Boolean{
			return _redoAvailable;
		}
		
		
		public function set redoAvailable(value:Boolean):void{
			_redoAvailable = value;
		}
		
		[Bindable]
		public function get undoAvailable():Boolean{
			
			return _undoAvailable;
		}
		
		public function set undoAvailable(value:Boolean):void{
			_undoAvailable = value;
		}

			
	}
}