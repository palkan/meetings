package ru.teachbase.module.documents {
import mx.collections.ArrayCollection;
import mx.rpc.Responder;

import ru.teachbase.components.uploader.UploadPanel;
import ru.teachbase.components.uploader.dialogs.LocalFileDialog;
import ru.teachbase.components.uploader.dialogs.RecentFilesDialog;
import ru.teachbase.manage.modules.model.IModuleContent;
import ru.teachbase.manage.modules.model.Module;
import ru.teachbase.model.App;
import ru.teachbase.module.documents.model.DocumentData;
import ru.teachbase.module.documents.model.FileItem;
import ru.teachbase.module.documents.model.WorkplaceData;
import ru.teachbase.utils.shortcuts.$null;
import ru.teachbase.utils.shortcuts.rtmp_history;
import ru.teachbase.utils.shortcuts.style;

public class DocumentsModule extends Module {

    private var _uploader:UploadPanel;

    public function DocumentsModule() {
        super('docs');

        _icon = style('docs', "icon");
        _iconHover = style('docs', "iconHover");

        new WorkplaceData();
        new DocumentData();
        new FileItem();


        _uploader = new UploadPanel();

        const dp:ArrayCollection = new ArrayCollection(
                [
                    new LocalFileDialog(),
                    new RecentFilesDialog()
                ]
        );

        _uploader.dataProvider = dp;

        rtmp_history("documents", new Responder(onHistory, $null));

    }

    private function onHistory(v:Array):void{
        for each(var _d:DocumentData in v) addDocument(_d);
    }

    /**
     *
     * @param doc
     */

    public function addDocument(doc:DocumentData, instance_id:int=0):void {

        if (App.meeting.docsById[doc.id] != undefined){
            App.meeting.docsById[doc.id].instance_id = instance_id;
            App.meeting.docsCollection.itemUpdated(App.meeting.docsById[doc.id]);
            return;
        }

        doc.instance_id = instance_id;

        App.meeting.docsById[doc.id] = doc;

        App.meeting.docsCollection.addItemAt(doc, 0);

    }

    /**
     *
     * @param doc
     */


    public function detachDocument(doc:DocumentData):void {

        if (!App.meeting.docsById[doc.id])
            return;

        App.meeting.docsById[doc.id].instance_id = 0;
        App.meeting.docsCollection.itemUpdated(App.meeting.docsById[doc.id]);

    }

    override public function getVisual(instanceID:int):IModuleContent {

        const result:IModuleContent = createInstance(instanceID);
        result && (result.ownerModule = this);
        return result;

    }


    override protected function createInstance(instanceID:int):IModuleContent {
        const result:WorkplaceContent = new WorkplaceContent();
        result.instanceID = instanceID;
        return result;
    }

    public function get uploader():UploadPanel {
        return _uploader;
    }
}
}