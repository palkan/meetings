package ru.teachbase.module.documents.model {
import ru.teachbase.utils.system.registerClazzAlias;

registerClazzAlias(FileItem);

public class FileItem {
    //---------- File types -------------//

    public static const IMAGE:String = 'image';
    public static const VIDEO:String = 'video';
    public static const AUDIO:String = 'audio';
    public static const DOCUMENT:String = 'document';
    public static const PRESENTATION:String = 'presentation';
    public static const TABLE:String = 'table';
    public static const WHITEBOARD:String = 'wb';

    public var name:String;
    public var url:String;
    public var thumb:String;

    /**
     * Type of document.
     * Can be:
     * <li> <i>wb</i></li>
     * <li> <i>image</i></li>
     * <li> <i>video</i></li>
     * <li> <i>audio</i></li>
     * <li> <i>document</i></li>
     * <li> <i>presentation</i></li>
     * <li> <i>table</i></li>
     */



    public var type:String;
    public var extension:String;
    public var params:Object;
    public var id:int;
    public var thumbs:Array;
    public var swfs:Array;

    public function FileItem(name:String = '', url:String = '', thumb:String = '', type:String = '', extension:String = '', id:int = 0, thumbs:Array = null, swfs:Array = null ) {
        this.name = name;
        this.url = url;
        this.thumb = thumb;
        this.type = type;
        this.extension = extension;
        this.params = params;
        this.id = id;
        this.thumbs = thumbs;
        this.swfs = swfs;
    }

    public function getParam(val:String):Object {
        if (!params)
            return null;

        return params[val];
    }

    /**
     *
     * Create FileItem from web server data.
     *
     * @param data
     * @return
     */

    public static function build(data:Object):FileItem {

        return new FileItem(
                data.name || "untitled",
                data.file,
                data.thumb,
                data.type,
                data.extension,
                data.id || 0,
                data.thumbs || [],
                data.swfs || []
        );

    }

}
}