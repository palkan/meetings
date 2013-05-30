package ru.teachbase.module.settings.components
{
import spark.components.List;
import spark.components.RadioButtonGroup;

public class RadioList extends List
	{
		
		private var _group:RadioButtonGroup;
		
		
		public function RadioList()
		{
			super();
		}

		public function get group():RadioButtonGroup
		{
			return _group;
		}

		public function set group(value:RadioButtonGroup):void
		{
			_group = value;
		}

	}
}