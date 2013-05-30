package ru.teachbase.model
{
	public class FileItem
	{
		private var _title:String; /// он же name отображает название
		private var _url:String; ///url на контент
		private var _thumbUrl:String; // ссылка на тамбунашку
		private var _type:String;
		private var _extention:String;		
		private var _params:Object;
		private var _id:int;
		
		public function FileItem($title:String = '', $url:String = '', $thumbUrl:String = '', $type:String = '', $extention:String = '', $id:int = 0, params:Object = null)
		{
			_title = $title;
			_url = $url;
			_thumbUrl = $thumbUrl;
			_type = $type;
			_extention = $extention;
			_params = params;
			_id = $id;
		}

		public function get extention():String
		{
			return _extention;
		}

		public function get type():String
		{
			return _type;
		}
		
		public function get thumbUrl():String
		{
			return _thumbUrl;
		}

		public function get url():String
		{
			return _url;
		}

		public function get title():String
		{
			return _title;
		}
		
		public function getParam(val:String):Object{
			if (!_params)
				return null;
			if (_params.hasOwnProperty(val))
				return _params[val];
			return null;
		}

		public function get id():int
		{
			return _id;
		}


	}
}