package ru.teachbase.manage.layout.model
{
import ru.teachbase.layout.model.*;
import ru.teachbase.utils.system.registerClazzAlias;

registerClazzAlias(LayoutChangeData);
	
	
	public class LayoutChangeData
	{
		
		public var type:String="default";
		public var data:LayoutElementData;
		public var from:Number;
		public var to:uint;
		public var l:uint = 0;
		public var i:uint = 0;
		public var d:int = 0;
		public var key:String = "";
		
		
		public function LayoutChangeData(obj:Object = null)
		{
            if(obj) fromObject(obj);
		}
		
		
		public function fromObject(obj:Object):void{
			
			for(var key:String in obj){
				
				this[key] = obj[key];
			
			}
			
			
			
			
		}
		
		
		
	}
}