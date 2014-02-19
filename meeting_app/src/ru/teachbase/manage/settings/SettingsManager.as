package ru.teachbase.manage.settings {

import mx.collections.ArrayCollection;

import ru.teachbase.components.settings.SettingsElement;
import ru.teachbase.components.settings.SettingsPanel;
import ru.teachbase.model.App;

public class SettingsManager {

    private var _panel:SettingsPanel = new SettingsPanel();
    private var _settingsPanels:Vector.<SettingsElement> = new <SettingsElement>[];
    private var _settingsLabels:ArrayCollection = new ArrayCollection();

    public function SettingsManager() {
        super();
    }

    /**
     *
     * @param id
     */

    public function show(id:int = 0):void {

        _panel.dataProvider = _settingsLabels;
        _panel.selectedIndex = id;

        App.view.lightbox.show(_panel);

    }

    /**
     *
     */

    public function close():void{
        App.view.lightbox.close();
    }

    /**
     *
     * @param element
     */


    public function addPanel(element:SettingsElement):void {
        _settingsPanels.push(element);
        _settingsLabels.addItem({iconOut: element.iconOut, iconOver: element.iconOver, label_id: element.label});
    }

    /**
     *
     * Return SettingsElement by index
     *
     * @param index
     * @return
     */

    public function getSettingsElement(index:int = 0):SettingsElement {

        if (index > _settingsPanels.length - 1 || index < 0)  return null;

        return _settingsPanels[index];
    }
}
}