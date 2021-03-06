package ru.teachbase.model
{
	public class ModuleSettings
	{
		
		public static const FUN:String = "function";
		public static const CHECK:String = "checkbox";
		
		
		public var type:String;
		public var handler:Function;
		public var moduleId:String;
		public var instanceId:int = 1;
		public var label:String;
		public var args:Array;
		
		public function ModuleSettings(label:String, type:String, handler:Function, ...args)			
		{
			this.type = type;
			this.handler = handler;
			this.label = label;
			this.args = args;
		}
		
				
		
		
	}
}