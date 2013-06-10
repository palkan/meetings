package ru.teachbase.traits
{
import ru.teachbase.module.documents.events.DocEvent;
import ru.teachbase.module.documents.model.DocChangeData;
import ru.teachbase.model.Packet;
import ru.teachbase.constants.PacketType;

[Event(name="change", type="ru.teachbase.module.documents.events.DocEvent")]
	[Event(name="state", type="ru.teachbase.module.documents.events.DocEvent")]
	[Event(name="load", type="ru.teachbase.module.documents.events.DocEvent")]
	/** Trait for document sharing.
	 * <br/>
	 * <b>Preparation</b>
	 * <br/>
	 * You have to call "new DocChangeData()" or smth like that to register allias for DocChangedata.
	 * <br/>
	 * <b>History</b>
	 * <br/>
	 * Use: 
	 * <br/>
	 * <code>
	 * trait.call("get_history", new Responder(onSuccess, onError), "doc", trait.instanceID);
	 * 
	 * function onSuccess(result:DocChangeData){...}
	 * </code>
	 * <br/>
	 * <i>result</i> contains all fields of DocChangeData non-empty.
	 * 
	 */

	
	public class DocTrait extends RTMPListener
	{
		public function DocTrait(id:uint)
		{
			super(PacketType.DOCUMENT, true);
			_instanceId = id;
		}
		
		
		public function reinit(id:int):void{
			
			_instanceId = id;
			
		}
		
		
		override protected function prepareOutputData(data:Object):Object{
			
			var _d:DocChangeData = new DocChangeData();
			_d.fromObject(data);
			
			return _d;
			
		}
		
		
		override protected function prepareInput(data:Object):Object{
			
			if(!(data is Packet)) return null;
			
			var p:Packet = data as Packet;
			
			if(p.minstance != _instanceId) return null;
						
			if(!(p.data is DocChangeData)) return null;

			return p.data; 
			
		}
		
		
		override protected function dispatchTraitEvent(data:Object):void{
			switch(data.type){
				case "change":
				{
					dispatchEvent(new DocEvent(DocEvent.CHANGE,(data as DocChangeData)));
					break;
				}
					
				default:
				{
					
					dispatchEvent(new DocEvent(DocEvent.LOAD, (data as DocChangeData)));
					break;
				}
				
			}
		}

    public function get instaneID():int{
        return _instanceId;
    }


	}
}