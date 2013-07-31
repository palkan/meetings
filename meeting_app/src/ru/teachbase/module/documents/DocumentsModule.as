package ru.teachbase.module.documents
{
import mx.collections.ArrayCollection;
import mx.rpc.Responder;

import ru.teachbase.manage.modules.model.IModuleContent;
import ru.teachbase.manage.modules.model.Module;
import ru.teachbase.module.documents.model.DocChangeData;
import ru.teachbase.utils.shortcuts.$null;
import ru.teachbase.utils.shortcuts.rtmp_history;
import ru.teachbase.utils.shortcuts.style;

public class DocumentsModule extends Module
	{
		private const HISTORY_LIMIT:int = 5;
		
		private var _docs:Object = {};
		
		
		[Bindable]
		public var docsCollection:ArrayCollection = new ArrayCollection();
		
		

		public function DocumentsModule()
		{
			super('docs');
			
			_icon = style('docs',"icon");
			_iconHover = style('docs',"iconHover");

            new DocChangeData();

			rtmp_history("docs",new Responder(onHistory,$null));
			
		}
		
		private function onHistory(v:Array):void
		{
			
			for each(var _d:DocChangeData in v){
				if(_d.type === "history"){
					docsCollection.addItem({id:_d.id,label:_d.title});
					_docs[_d.id] = {title:_d.title};
				}
			}
			
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
			

		override protected function createInstance(instanceID:int):IModuleContent
		{
			const result:WorkplaceContent = new WorkplaceContent();
			result.instanceID = instanceID;
			return result;
		}
	}
}