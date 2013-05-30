package ru.teachbase.components.tree
{
import flash.events.EventDispatcher;
import flash.utils.Dictionary;

import mx.collections.IList;
import mx.events.CollectionEvent;
import mx.events.CollectionEventKind;

public class TreeDataProvider extends EventDispatcher implements IList
	{
		private var _dataProvider:IList;
		
		public function TreeDataProvider(dataProvider:IList)
		{
			super(null);
			_dataProvider = dataProvider;
			_length = dataProvider.length;
			
			updateStates();
		}
		
		//--------------------------------------------------------------------------
		//
		//  Implementation of IList: methods
		//
		//--------------------------------------------------------------------------
		
		public function addItem(item:Object):void
		{
			_dataProvider.addItem(item);
		}
		
		public function addItemAt(item:Object, index:int):void
		{
			_dataProvider.addItemAt(item, index);
		}
				
		public function getItemIndex(item:Object):int{
			return _dataProvider.toArray().indexOf(item);
		}
		
		public function removeAll():void
		{
			_dataProvider.removeAll();
		}
		
		
		public function removeItemAt(index:int):Object
		{
			return null;
		}
		
		public function setItemAt(item:Object, index:int):Object
		{
			return _dataProvider.setItemAt(item, index);
		}
		
		public function toArray():Array
		{
			return _dataProvider.toArray();	
		}
		
		private function updateStates():void{
			var event:CollectionEvent = new CollectionEvent(CollectionEvent.COLLECTION_CHANGE,
				false, false, CollectionEventKind.RESET);
			dispatchEvent(event);
		}
		
		private var _length:int;
		
		[Bindable("collectionChange")]
		public function get length():int
		{
			//trace('length geted ', _dataProvider ? _dataProvider.length : 0)
			
			//return _dataProvider ? _dataProvider.length : 0;
			return _length;
		}
		
		public function itemUpdated(item:Object, property:Object = null, oldValue:Object = null, newValue:Object = null):void {
			
		}
		
		//------- get item
		
		public function getItemAt(index:int, prefetch:int=0):Object {
			curentId = 0;
			return findItemAt(index,_dataProvider.toArray());
			// добаить кеш
		}
		
		private var curentId:int = 0;
		
		private function findItemAt(targetId:int, arr:Array, depth:int = 0):Object{
			var i:int;
			while (i < arr.length) {
				//trace('наш новый итеральный цикл работает ', curentId , targetId, 'длинна массива', arr.length, 'depth', depth, " i ", i);
				var el:Object = arr[i];
				if (!el) return null; 
				
				if (curentId == targetId) {
					if (_openedBranches[el.id]) { // убрать нах
						el.opened = true;
					}else{
						el.opened = false;
					}
					return el;
				}
				
				curentId++;
				
				if (_openedBranches[el.id]) {
					var obj:Object = findItemAt(targetId, _openedBranches[el.id].children, depth++);
					if (obj) 
						return obj;
				}
				i++;
			}
			
			return null;
		}
		
		//---- end of get item
				
		//--------------------------------------------------------------------------
		//
		//  Tree methods:
		//
		//--------------------------------------------------------------------------
			
		private var _openedBranches:Dictionary = new Dictionary();
		
		public function openBranch(obj:Object):void{
			_length += obj.children.length;
			_openedBranches[obj.id] = obj;
			updateStates();
		}
		
		public function closeBranch(obj:Object):void{
			closeAllChildrenBranch(obj)
			updateStates();
		}
		
		public function closeAllChildrenBranch(object:Object):void{
			if (!_openedBranches[object.id])
				return;
			
			for each (var obj:Object in object.children) {
				if (_openedBranches[obj.id] && _openedBranches[obj.id].children)
					closeAllChildrenBranch(_openedBranches[obj.id]);
				
			}
			_length -= object.children.length;
			delete _openedBranches[object.id];
		}
		
	}
}