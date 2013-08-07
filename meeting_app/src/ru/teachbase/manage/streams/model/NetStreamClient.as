/**
 * User: palkan
 * Date: 6/10/13
 * Time: 5:43 PM
 */
package ru.teachbase.manage.streams.model {
import ru.teachbase.model.App;
import ru.teachbase.utils.Strings;
import ru.teachbase.utils.shortcuts.debug;

public dynamic class NetStreamClient {

    private var _data:StreamData;

    private var _hasVideo:Boolean = false;

    private var _hasAudio:Boolean = false;

    public function NetStreamClient(data:StreamData) {
        _data = data;
    }

    public function get data():StreamData {
        return _data;
    }

    public function onMetaData(metadata:Object):void{
        debug('stream meta:',metadata);

        updateAVStatus(metadata);
    }

    public function onAudioVideoStatus(status:Object):void{
        debug('stream av status: ',status);

        updateAVStatus(status);
    }


    private function updateAVStatus(object:Object):void{

        _hasAudio = object['hasAudio'] ? Strings.serialize(object['hasAudio']) : false;
        _hasVideo = object['hasVideo'] ? Strings.serialize(object['hasVideo']) : false;

        _data && App.meeting.streamsByName[_data.name] && App.meeting.streamList.itemUpdated(App.meeting.streamsByName[_data.name]);

    }


    public function get hasAudio():Boolean {
        return _hasAudio;
    }

    public function get hasVideo():Boolean {
        return _hasVideo;
    }
}
}
