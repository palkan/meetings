/**
 * User: palkan
 * Date: 6/10/13
 * Time: 5:43 PM
 */
package ru.teachbase.manage.streams.model {
import ru.teachbase.model.App;
import ru.teachbase.net.stats.RTMPWatch;
import ru.teachbase.utils.Strings;
import ru.teachbase.utils.shortcuts.debug;

public dynamic class NetStreamClient {

    private var _data:StreamData;

    private var _metadata:Object = {};

    private var _watcher:RTMPWatch;

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

        for (var key:String in metadata) _metadata[key] = metadata[key];

        updateAVStatus(metadata);

        _data && App.meeting.streamsByName[_data.name] && App.meeting.streamList.itemUpdated(App.meeting.streamsByName[_data.name]);
    }

    public function onAudioVideoStatus(status:Object):void{
        debug('stream av status: ',status);

        updateAVStatus(status);

        _data && App.meeting.streamsByName[_data.name] && App.meeting.streamList.itemUpdated(App.meeting.streamsByName[_data.name]);
    }


    private function updateAVStatus(object:Object):void{

        (object['hasAudio'] != undefined) && (_hasAudio =  Strings.serialize(object['hasAudio']));
        (object['hasVideo'] != undefined) && (_hasVideo =  Strings.serialize(object['hasVideo']));

    }


    public function get hasAudio():Boolean {
        return _hasAudio;
    }

    public function get hasVideo():Boolean {
        return _hasVideo;
    }

    public function get watcher():RTMPWatch {
        return _watcher;
    }

    public function set watcher(value:RTMPWatch):void {
        _watcher = value;
    }

    public function get metadata():Object {
        return _metadata;
    }
}
}
