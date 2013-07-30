package ru.teachbase.layout.model
{

import ru.teachbase.utils.system.registerClazzAlias;

registerClazzAlias(LayoutElementData);
	
	public class LayoutElementData
	{
		public var width:int;
		
		public var height:int;
		
		public var layout:uint;
		
		public var id:int;

        public var module:String = '';

        public var instance_id:int = 0;

        private var _key:String;

		public function LayoutElementData(width:int = 100, height:int = 100, panel_id:int = 1, layout:int = 0, module:String = '', instance_id:uint = 0){
		
			this.width = width;
			this.height = height;
			this.id = panel_id;
			this.layout = layout;
            this.instance_id = instance_id;
            this.module = module;
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

        public function set key(value:String):void {
            _key = value;
        }
    }
}