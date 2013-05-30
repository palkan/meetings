package ru.teachbase.model
{
import ru.teachbase.utils.registerClazzAlias;

registerClazzAlias(DocChangeData);
	
	public dynamic class DocChangeData
	{
		
		
		
		
		/**
		 * Type of change.
		 * Can be:
		 * <li> <i>loading</i>, <i>idle</i> - for state change </li>
		 * <li> <i>load</i> - for start working with document</li>
		 * <li> <i>change</i> - document's transformation (special for every renderer) </li>
		*/		
		
		public var type:String;
		
		/** File id (bitrix id from material library?)
		 * 
		 */
				
				
		public function DocChangeData()
		{
		}
		
		
		public function fromObject(obj:Object):void{
			
			for(var key:String in obj){
				
				this[key] = obj[key];
				
			}
			
		}
		
	}
}