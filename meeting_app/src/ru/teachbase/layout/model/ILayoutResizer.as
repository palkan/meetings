/**
 * User: palkan
 * Date: 7/2/13
 * Time: 6:49 PM
 */
package ru.teachbase.layout.model {

/**
 *
 * Layout resizer element interface
 *
 */

public interface ILayoutResizer{

    function set model(value:ResizerModel):void;
    function hide():void;
    function get key():String;

}
}
