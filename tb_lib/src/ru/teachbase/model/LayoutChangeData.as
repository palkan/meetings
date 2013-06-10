package ru.teachbase.model
{
import ru.teachbase.utils.registerClazzAlias;

registerClazzAlias(LayoutChangeData);
	
	
	public class LayoutChangeData
	{
		
		public var type:String="default";
		public var data:LayoutElementData;
		public var from:uint;
		public var to:uint;
		public var l:uint = 0;
		public var i:uint = 0;
		public var d:int = 0;
		public var key:String = "";
		
		
		public function LayoutChangeData()
		{
		}
		
		
		public function fromObject(obj:Object):void{
			
			for(var key:String in obj){
				
				this[key] = obj[key];
			
			}
			
			
			
			
		}
		
		
		
	}
}