package ru.teachbase.traits
{
import ru.teachbase.module.settings.events.SettingsEvent;
import ru.teachbase.model.Packet;
import ru.teachbase.module.settings.model.Setting;
import ru.teachbase.constants.PacketType;

public class SettingsTrait extends RTMPListener
	{
		//---- propertyes list-------//
    public function SettingsTrait()
		{
			super(PacketType.SETTINGS_CHANGED,true);
			_readyToReceive = true;
		}
		
		
		override protected function prepareInput(data:Object):Object{
			
			if(!(data is Packet)) return null;
			
			var p:Packet = data as Packet;
			
			if(!(p.data is Setting)) return null;
			
			return (p.data as Setting); 
			
		}
		
		override protected function dispatchTraitEvent(data:Object):void{
			dispatchEvent(new SettingsEvent((data as Setting).valueName, data as Setting));
			
		}
		
	}
}