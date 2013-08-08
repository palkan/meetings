/**
 * User: palkan
 * Date: 5/31/13
 * Time: 3:43 PM
 *
 * Almost useless now...
 */
package ru.teachbase.manage.modules {
import mx.rpc.Responder;

import ru.teachbase.constants.PacketType;
import ru.teachbase.manage.Manager;
import ru.teachbase.manage.modules.model.IModule;
import ru.teachbase.manage.modules.model.ModuleClass;
import ru.teachbase.manage.modules.model.ModuleInstanceData;
import ru.teachbase.manage.session.model.Meeting;
import ru.teachbase.model.App;
import ru.teachbase.utils.helpers.getValue;
import ru.teachbase.utils.helpers.isArray;
import ru.teachbase.utils.shortcuts.error;
import ru.teachbase.utils.shortcuts.rtmp_history;

public class ModulesManager extends Manager {

    private var _model:Meeting;

    public function ModulesManager(registered:Boolean = false) {
        super(registered);
        new ModuleInstanceData();
    }


    override protected function initialize(reinit:Boolean = false):void{

        if(initialized) return;

        if(reinit){
            reinitialize();
            return;
        }

        _model = App.meeting;

       rtmp_history(PacketType.MODULE,new Responder(handleHistory,function (...args):void{ error("Modules history load failed");_failed = true;}));
    }

    /**
     *
     * We assume that available modules are not changed, so simply dispatch INITIALIZED event.
     *
     * @inherit
     */

    protected function reinitialize():void{

        _initialized = true;
    }

    //------------- API -----------------//


    override public function dispose():void{
        if(_disposed) return;
        super.dispose();
    }

    //------------ handlers -------------//

    protected function handleHistory(modules_data:*):void{

        var module_ids:Array = getValue(modules_data,"modules",[],isArray);

        for each(var moduleId:String in module_ids) initializeModule(moduleId);

        _initialized = true;
    }

    //-------------internal -----------//


    protected function initializeModule(moduleId:String):void
    {
        // existing:
        if(_model.modules[moduleId]) return;

        var moduleClazz:Class = ModuleClass.getClassById(moduleId);

        if(!moduleClazz) return;

        var module:IModule = new moduleClazz();

        // register:
        _model.modules[moduleId] = module;
        _model.modules[module] = module.moduleId;

        // init:
        module.initializeModule(this);

        _model.modulesCollection.addItem(module);

    }

    protected function initializeInstance(data:ModuleInstanceData):Boolean{

        if(!_model.modules[data.moduleId]) return false;

        if((_model.modules[data.moduleId] as IModule).getVisual(data.instanceId)){
            _model.instances.push(data);
            _model.instancesById[data.moduleId+":"+data.instanceId] = data;
            _model.instancesById[data.panelId] = data;
            return true;
        }


        return false;
    }


}
}
