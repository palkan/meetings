/**
 * User: palkan
 * Date: 5/27/13
 * Time: 1:17 PM
 */
package ru.teachbase.layout {
public class LayoutClient {
    public function LayoutClient() {
    }

    protected function onLayoutChanged(event:LayoutEvent):void
    {

        Logger.log("onLayoutChanged: "+_useVirtual+"; type: "+event.data.type,'layout');


        if(_useVirtual)
            cancelLocalUncommitedChanges();

        useVirtual = false;

        switch(event.data.type){

            case "move":
                move(event.data.from,event.data.to,event.data.l,event.data.i);
                break;
            case "resize":
                currentModel.resize_group(event.data.key,event.data.d);
                updateDisplayList();
                break;

            case "add":
                addElementExternal(event.data.from,event.data.to,event.data.data,event.data.i,event.data.l);
                break;

            case "remove":
                removeByID(event.data.from);
                break;
            case "restart":
                restartByID(event.data.from,event.data.data);
                break;
            case "module_click":
                prepareAutoAdd(event.data.data.content[0].module);
                break;
            default:
                break;
        }



    }


    if(initElement(element)){
        _trait.output({type:"add",to:elementTo ? elementTo.elementID : -1,from:element.elementID,l:layout,i:index,data:_data},Recipients.ALL);
        if(useVirtual)
            _model.elements[element.elementID] = element;
    }else{
        _trait.output({type:"move",to:elementTo ? elementTo.elementID : -1,from:element.elementID,l:layout,i:index},Recipients.ALL);
    }

    protected function addElementExternal(elementID:uint, elementTo:uint, data:LayoutElementData,index:uint,layout:uint):void{

        if(!exists(elementTo) && model.num>0)
            return;

        var element:IModulePanel;

        if(!exists(elementID)){
            element = createNewElement(_manager.getModule(data.content[0]["module"])) as IModulePanel;
            initElement(element);
        }else{
            element = _model.elements[elementID];
        }


        if(data.content){
            var _instance:IModuleContent = _manager.getInstanceForLayout(data.content[0]["module"],data.content[0]["id"]);
            element.content = [_instance];
            element.title = _instance.label;
            _instance.panelID = elementID;
        }

        if(_model.num === 0)
            _model.init(data);
        else if(elementTo === 0)
            currentModel.addAbove(data,index,layout);
        else
            _model.add((_model.elements[elementTo] as ITreeLayoutElement).layoutIndex,data,index,layout);

        updateDisplayList();
    }


    element.active = false;
    delete currentModel.elements[element.elementID];
    if(!from)
        _trait.output({type:"remove",from:element.elementID},Recipients.ALL);
    if(!useVirtual){
        _container.removeElement(element);
    }


    _container.setElementIndex(module,_container.numElements-1);

    _expanded = true;

    (_expandedTarget as IDraggle).dragBehavior.active = false;


    override protected function cancelLocalUncommitedChanges():void
    {
        (_manager.moduleContainer as ModuleContainer).cancelDragDrop();
    }

}
}
