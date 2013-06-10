package ru.teachbase.utils
{
import flash.errors.IllegalOperationError;
import flash.utils.Dictionary;

import ru.teachbase.utils.interfaces.IDisposable;

public final class Disposer
	{
		
		private var list:Dictionary = new Dictionary(true);
		
		private static const instance:Disposer = new Disposer();
		
		public function Disposer()
		{
			if(instance)
				throw new IllegalOperationError('Disposer is a singleton');
		}
		
		
		public static function addItem(item:IDisposable):void{
			instance.list[item] = true;
		}
		
		
		public static function dispose():void{
			for (var item:Object in instance.list)
				!(item as IDisposable).disposed && (item as IDisposable).dispose();
		}
		
		
		
	}
}