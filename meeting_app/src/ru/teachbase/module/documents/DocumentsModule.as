package ru.teachbase.module.documents
{
import mx.collections.ArrayCollection;
import mx.rpc.Responder;

import ru.teachbase.manage.LayoutManager;
import ru.teachbase.manage.TraitManager;
import ru.teachbase.model.DocChangeData;
import ru.teachbase.module.base.IModuleContent;
import ru.teachbase.module.base.Module;
import ru.teachbase.traits.DocTrait;
import ru.teachbase.utils.helpers.*;
import ru.teachbase.utils.shortcuts.style;

public class DocumentsModule extends Module
	{
		private const HISTORY_LIMIT:int = 5;
		
		private var _docs:Object = {};
		
		
		[Bindable]
		public var docsCollection:ArrayCollection = new ArrayCollection();
		
		
		private var trait:DocTrait;
		
		public function DocumentsModule()
		{
			super('docs');
			
			_icon = style('docs',"icon");
			_iconHover = style('docs',"iconHover");
			
			trait = TraitManager.instance.createTrait(DocTrait,false,0) as DocTrait;
			
			trait.call("get_history",new Responder(onHistory,null),"docs");
			
		}
		
		private function onHistory(v:Array):void
		{
			
			for each(var _d:DocChangeData in v){
				if(_d.type === "history"){
					docsCollection.addItem({id:_d.id,label:_d.title});
					_docs[_d.id] = {title:_d.title};
				}
			}
			
			trait.dispose();
			
		}		
		
		
		public function registerNewDoc(_id:int, _title:String):void{
			
			if(_docs[_id]!=undefined)
				return;
			
			_docs[_id] = {title:_title};
			
			if(docsCollection.length === HISTORY_LIMIT){
				
				var _itm:Object = docsCollection.getItemAt(HISTORY_LIMIT-1);
				delete _docs[_itm.id];
				docsCollection.removeItemAt(HISTORY_LIMIT-1);
				
			}
						
			docsCollection.addItemAt({label:_title, id:_id},0);
			
		}
		
		override public function getVisual(instanceID:int):IModuleContent{
			
			const result:IModuleContent = createInstance(instanceID);
			result && (result.ownerModule = this);
			return result;
			
		}
			
				
		override public function initializeModule(manager:LayoutManager):void
		{
			super.initializeModule(manager);
			new DocChangeData();
		}
		
		override protected function createInstance(instanceID:int):IModuleContent
		{
			const result:WorkplaceContent = new WorkplaceContent();
			result.instanceID = instanceID;
			return result;
		}
	}
}