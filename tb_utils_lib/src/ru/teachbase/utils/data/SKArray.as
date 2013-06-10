package ru.teachbase.utils.data
{
	public final class SKArray
	{
		
		private var _object:Object;
		
		private var _length:int;
		
		public function SKArray()
		{
			
			_object = new Object();
			
		}
		
		
		public function add(key:String,value:*):int{
			
			if(_object[key] == undefined){
				_object[key] = {data:value,index:length};
				_object[_length] = key;
				_length++;
			}
			
			
			return _length;
			
		}
		
		
		public function get(key:String):*{
			if(_object[key] != undefined)
				return _object[key]["data"];
			else
				return undefined;
			
		}
		
		
		public function getByIndex(i:int):*{
			if(_object[i] != undefined)
				return _object[_object[i]]["data"];
			else
				return undefined;
			
		}
		
		
		public function remove(key:String):int{
			
			if(_object[key] != undefined){
				_object[_object[key]["index"]] = null;
				_object[key] = null;
				_length--;
			}			
			
			return length;
		}
		

		public function get length():int
		{
			return _length;
		}
		
		
	}
}