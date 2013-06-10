package ru.teachbase.utils
{
import flash.errors.IllegalOperationError;
import flash.utils.Dictionary;

import ru.teachbase.utils.interfaces.ILocalable;

public final class Localizer
	{
		
		private var list:Dictionary = new Dictionary(true);
		
		private static const instance:Localizer = new Localizer();
		
		public function Localizer()
		{
			if(instance)
				throw new IllegalOperationError('Localizer is a sinlegton');
		}
		
		
		public static function addItem(item:ILocalable):void{
			instance.list[item] = true;
		}
		
		
		public static function localize():void{
			for (var item:Object in instance.list)
				(item as ILocalable).localize();
		}
		
		
		
	}
}
