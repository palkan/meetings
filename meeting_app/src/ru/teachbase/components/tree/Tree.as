package ru.teachbase.components.tree
{
import mx.collections.IList;

import spark.components.List;

public class Tree extends List
	{
		private var _dataProvider:TreeDataProvider;
		
		public function Tree()
		{
			super();
			
		}
		
		override public function set dataProvider(value:IList):void{
			_dataProvider = value is TreeDataProvider ? value as TreeDataProvider : new TreeDataProvider(value);
			
			super.dataProvider = _dataProvider;
		}
		
		public function expandItem(data:Object,isOpen:Boolean):void{
			if (!data || !data.children)
				return;
		
			if (isOpen) {
				_dataProvider.openBranch(data);
			}else{
				_dataProvider.closeBranch(data);
			}
		}
	}
}