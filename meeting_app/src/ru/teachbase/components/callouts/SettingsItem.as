package ru.teachbase.components.callouts
{
	public class SettingsItem
	{
		
		public static const FUN:String = "function";
		public static const CHECK:String = "checkbox";
		
		
		public var type:String;
		public var handler:Function;
		public var label:String;
		public var args:Array;
		
		public function SettingsItem(label:String, type:String, handler:Function, ...args)
		{
			this.type = type;
			this.handler = handler;
			this.label = label;
			this.args = args;
		}
		
				
		
		
	}
}