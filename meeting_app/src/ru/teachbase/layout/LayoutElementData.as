package ru.teachbase.layout
{

import ru.teachbase.utils.system.registerClazzAlias;

registerClazzAlias(LayoutElementData);
	
	public class LayoutElementData
	{
		public var width:int;
		
		public var height:int;
		
		public var layout:uint;
		
		public var id:int;

        private var _key:String;

		public function LayoutElementData(width:int = 100, height:int = 100, instance:int = 1, layout:int = 0){
		
			this.width = width;
			this.height = height;
			this.id = instance;
			this.layout = layout;
		}
		
		
		
		public function clone():LayoutElementData{
			
			var r:LayoutElementData = new LayoutElementData(this.width,this.height,this.id,this.layout);
			return r;
			
			
			
		}
		
		
		public function toString():String{
			return "{width:"+this.width.toString()+", height:"+this.height.toString()+", instance:"+this.id.toString()+", layout:"+this.layout.toString()+"}";
		}

        public function get key():String {
            return _key;
        }
    }
}