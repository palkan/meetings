/**
 * User: palkan
 * Date: 6/10/13
 * Time: 5:43 PM
 */
package ru.teachbase.manage.streams.model {
public dynamic class NetStreamClient {

    private var _data:StreamData;


    public function NetStreamClient(data:StreamData) {
        _data = data;
    }

    public function get data():StreamData {
        return _data;
    }

    public function onMetaData(data:Object):void{
        //TODO: or not todo?
    }
}
}
