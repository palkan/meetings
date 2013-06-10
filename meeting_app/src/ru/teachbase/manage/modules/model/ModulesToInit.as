package ru.teachbase.manage.modules.model
{

	public class ModulesToInit
	{
		
		public var  modules:Array;
		public var panel:uint;
		
		public function ModulesToInit(modules:Array,panelId:uint)
		{
			this.modules = modules;
			this.panel = panelId;
		}
	}
}