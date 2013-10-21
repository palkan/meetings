/**
 * User: palkan
 * Date: 10/18/13
 * Time: 5:29 PM
 */
package ru.teachbase.manage.docs {
import mx.rpc.Responder;

import ru.teachbase.constants.PacketType;
import ru.teachbase.manage.Manager;
import ru.teachbase.model.App;
import ru.teachbase.module.documents.model.DocumentData;
import ru.teachbase.utils.shortcuts.$null;
import ru.teachbase.utils.shortcuts.rtmp_history;

public class DocsManager extends Manager {
    public function DocsManager(registered:Boolean = false, dependenciesClasses:Array = null) {
        super(registered, dependenciesClasses);
    }


    override protected function initialize(reinit:Boolean = false):void{

        super.initialize(reinit);

        rtmp_history(PacketType.DOCUMENTS_LIST, new Responder(handleHistory, $null));

    }


    override public function clear():void{

        super.clear();

        for each(var d:DocumentData in App.meeting.docsCollection.source)
            delete App.meeting.docsById[d.id];

        App.meeting.docsCollection.removeAll();

    }

    protected function handleHistory(data:Array):void{
        for each(var _d:DocumentData in data) addDocument(_d,-1);

        _initialized = true;
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

        (instance_id>=0) && (doc.instance_id = instance_id);

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
}
}
