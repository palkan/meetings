package ru.teachbase.manage.layout.model {
import ru.teachbase.layout.model.*;
import ru.teachbase.utils.extensions.FromObject;
import ru.teachbase.utils.system.registerClazzAlias;

registerClazzAlias(LayoutChangeData);


public class LayoutChangeData extends FromObject{

    public var type:String = "default";
    public var data:LayoutElementData;
    public var from:Number = 0;
    public var to:uint;
    public var l:uint = 0;
    public var i:uint = 0;
    public var d:int = 0;
    public var key:String = "";
    public var layout:Object;

    public function LayoutChangeData(obj:Object = null) {
        super(obj);
    }
}
}