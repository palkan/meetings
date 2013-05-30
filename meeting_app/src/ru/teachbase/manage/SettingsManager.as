package ru.teachbase.manage
{

import mx.collections.ArrayCollection;

import ru.teachbase.core.Core;
import ru.teachbase.module.settings.SettingsElement;
import ru.teachbase.module.settings.SettingsPanel;

public class SettingsManager extends SettingsManagerBase
	{
		
		private var _panel:SettingsPanel;
		private var _settingsContents:Array = new Array();
		private var _settingsLabels:ArrayCollection = new ArrayCollection();
		
		public function SettingsManager()
		{
			super();
		}
		
		public function showDialog(id:int = 0):void{
			if (_panel == null) _panel = new SettingsPanel()
			Core.addPopupToTop(_panel);
			_panel.navigateToPanel(id);
		}
		
		public function addSettingsPanel(Element:Class):void{
			_settingsContents.push(Element);
			_settingsLabels.addItem({iconOut:Element.iconOut,iconOver:Element.iconOver,skinName:Element.skinName,loc_id:Element.label});
		}
		
		
			
		
		public function get panelsList():ArrayCollection {
			return _settingsLabels;
		}
		
		public function getSettingsElement(id:int):SettingsElement{
			if (id>_settingsContents.length-1 || id == -1) {return null}
			if (_settingsContents[id] is SettingsElement) {
				return _settingsContents[id];
			}else{
				const SettingsClass:Class = _settingsContents[id] as Class;
				return _settingsContents[id] = new SettingsClass();
			}
		}
	}
}