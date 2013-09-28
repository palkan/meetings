/**
 * User: palkan
 * Date: 8/19/13
 * Time: 2:32 PM
 */
package ru.teachbase.components.board.model {
import ru.teachbase.utils.system.registerClazzAlias;

public class StyleData {

    registerClazzAlias(StyleData);

    public var color:uint;
    public var stroke:Number;
    public var fillColor:uint;

    public function StyleData(color:uint = 0x000000, stroke:Number = 1, fillColor:uint = 0xffffff) {

        this.color = color;
        this.stroke = stroke;
        this.fillColor = fillColor;

    }
}
}
