package ru.teachbase.model
{

import ru.teachbase.utils.registerClazzAlias;

registerClazzAlias(LayoutElementData);
	
	public class LayoutElementData
	{
		public var width:int;
		
		public var height:int;
		
		public var layout:uint;
		
		public var id:int;
		
		public var privacy:Boolean;
		
		public var content:Array;
		
		private var _key:String='';
		
		public function LayoutElementData(width:int = 100, height:int = 100, instance:int = 1, privacy:Boolean = false, layout:int = 0, content:Array = null, key:String = ''){
		
			this.width = width;
			this.height = height;
			this.id = instance;
			this.layout = layout;
			this.privacy = privacy;
			this.content = content;
			
			_key = key; // temp!!!
		}
		
		
		
		public function clone():LayoutElementData{
			
			var r:LayoutElementData = new LayoutElementData(this.width,this.height,this.id,this.privacy,this.layout,this.content);
			return r;
			
			
			
		}
		
		
		public function toString():String{
			
			
			return "{key:"+this.key+", width:"+this.width.toString()+", height:"+this.height.toString()+", instance:"+this.id.toString()+", layout:"+this.layout.toString()+", privacy:"+this.privacy.toString()+"}"; 
			
			
			
		}
		
		
		/**
		 * key of node for data
		 * 
		 * use only when parsing server response with layout!
		 */
		
		public function get key():String
		{
			return _key;
		}
		
		
		public function set key(value:String):void
		{
			_key = value;
		}
		

		

		
	}
}