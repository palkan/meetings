/**
 * User: palkan
 * Date: 5/31/13
 * Time: 3:43 PM
 */
package ru.teachbase.manage.modules {
import mx.rpc.Responder;

import ru.teachbase.constants.PacketType;
import ru.teachbase.events.GlobalEvent;
import ru.teachbase.manage.Manager;
import ru.teachbase.manage.modules.model.IModule;
import ru.teachbase.manage.modules.model.ModuleClass;
import ru.teachbase.manage.modules.model.ModuleInstanceData;
import ru.teachbase.manage.rtmp.RTMPListener;
import ru.teachbase.manage.rtmp.events.RTMPEvent;
import ru.teachbase.manage.session.model.Meeting;
import ru.teachbase.model.App;
import ru.teachbase.utils.helpers.getValue;
import ru.teachbase.utils.helpers.isArray;
import ru.teachbase.utils.shortcuts.error;
import ru.teachbase.utils.shortcuts.rtmp_call;
import ru.teachbase.utils.shortcuts.rtmp_history;
import ru.teachbase.utils.shortcuts.warning;

public class ModulesManager extends Manager {

    private const _listener:RTMPListener = new RTMPListener(PacketType.MODULE);
    private var _model:Meeting;

    public function ModulesManager(registered:Boolean = false) {
        super(registered);
        new ModuleInstanceData();


    }


    override protected function initialize():void{

        if(initialized) return;

        _model = App.meeting;

        _listener.addEventListener(RTMPEvent.DATA, handleMessage);
        _listener.initialize();
        rtmp_history(PacketType.MODULE,new Responder(handleHistory,function (...args):void{ error("Modules history load failed");_failed = true;}));
    }


    //------------- API -----------------//

    /**
     *
     * Call before adding new module to layout or display list.
     *
     * @param module
     * @param callback
     */

    public function registerModuleInstance(moduleId:String,callback:Function = null):void{

        rtmp_call("register_module", new Responder(callback, moduleRegisterFailed), moduleId);

        function moduleRegisterFailed(error:*):void{
            warning("Module register failed:",error);
        }

    }

    /**
     *
     * Call before remove module from layout or display list.
     *
     * @param instance
     * @param callback
     */

    public function unregisterModuleInstance(instance:ModuleInstanceData,callback:Function = null):void{

        rtmp_call("unregister_module", new Responder(callback, moduleUnRegisterFailed), instance.moduleId, instance.instanceId);

        function moduleUnRegisterFailed(error:*):void{
            warning("Module unregister failed:",error);
        }

    }


    override public function dispose():void{
        if(_disposed) return;
        _listener.dispose();
        super.dispose();
        //TODO:
    }

    //------------ handlers -------------//

    protected function handleHistory(modules_data:*):void{

        var module_ids:Array = getValue(modules_data,"modules",[],isArray);

        for each(var moduleId:String in module_ids) initializeModule(moduleId);

        var instances:Array = getValue(modules_data,"instances",[],isArray);

        for each(var moduleData:ModuleInstanceData in instances) initializeInstance(moduleData);

        _listener.readyToReceive = true;
        _initialized = true;

    }


    private function handleMessage(e:RTMPEvent):void {

        var data:ModuleInstanceData = e.packet.data as ModuleInstanceData;

        if(!data) return;

        // if panelId is 0 then module is removed

        if(!data.panelId){
            var instance:ModuleInstanceData = _model.instancesById[data.moduleId+":"+data.instanceId];
            if(!instance) return;

            _model.instances.splice(_model.instances.indexOf(instance),1);
            delete _model.instancesById[data.moduleId+":"+data.instanceId];

            GlobalEvent.dispatch(GlobalEvent.MODULE_REMOVE,instance);
        }else{
            if(initializeInstance(data)) GlobalEvent.dispatch(GlobalEvent.MODULE_ADD,data);
        }

    }


    //------------- get/set -----------//

    public function get instances():Vector.<ModuleInstanceData>{
        return _model.instances;
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
            return true;
        }


        return false;
    }


}
}
