package ru.teachbase.core
{
import flash.display.Stage;

import mx.core.FlexGlobals;
import mx.managers.FocusManager;
import mx.managers.IFocusManagerContainer;

import ru.teachbase.manage.TraitManager;
import ru.teachbase.model.NetModel;
import ru.teachbase.model.RoomModel;
import ru.teachbase.net.Service;
import ru.teachbase.utils.Configger;

/**
	 * Application model
	 * 
	 * @author Teachbase (created: Apr 26, 2012)
	 */
	public class App
	{
		
		private static var _focusManager:FocusManager;
		public static const traitManager:TraitManager = TraitManager.instance;
		
		public static var net:NetModel;
		public static const room:RoomModel = new RoomModel();
		public static const config:Configger = Configger.instance;
		
		
		public static const service:Service = new Service();
		
		
		//------------ constructor ------------//
		
		public function App()
		{
		}
		
		//------------ initialize ------------//
		
		//--------------- ctrl ---------------//
		
		public static function get focusManager():FocusManager{
			if(!_focusManager)
				_focusManager=new FocusManager(FlexGlobals.topLevelApplication as IFocusManagerContainer);
			
			return _focusManager;
		}
		
		
		public static function get stage():Stage{
			if (Core.instance)
				return Core.instance.stage;
			
			return null;
		}
		
		
		public static function get mode():String{
			return Core.instance.mode;
		}
		
		
		//------------ get / set -------------//
			
		//------- handlers / callbacks -------//
	}
}