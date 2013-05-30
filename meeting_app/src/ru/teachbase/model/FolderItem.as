package ru.teachbase.model
{
	public class FolderItem
	{
		
		private var _id:int;
		private var _level:int;
		private var _parent:int
		private var _title:String;
		public var children:Array;
		
		public function FolderItem($id:int, $level:int, $parentId:int, $title:String)
		{
			_id = $id;
			_level = $level;
			_parent = $parentId;
			_title = $title;
		}

		public function get title():String
		{
			return _title;
		}

		public function get id():int
		{
			return _id;
		}

	}
}