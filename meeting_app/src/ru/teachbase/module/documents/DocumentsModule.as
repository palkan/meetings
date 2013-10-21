package ru.teachbase.module.documents {
import mx.collections.ArrayCollection;

import ru.teachbase.components.uploader.UploadPanel;
import ru.teachbase.components.uploader.dialogs.LocalFileDialog;
import ru.teachbase.components.uploader.dialogs.RecentFilesDialog;
import ru.teachbase.manage.modules.model.IModuleContent;
import ru.teachbase.manage.modules.model.Module;
import ru.teachbase.module.documents.model.DocumentData;
import ru.teachbase.module.documents.model.FileItem;
import ru.teachbase.module.documents.model.WorkplaceData;
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