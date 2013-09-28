/**
 * User: VOVA
 * Date: 25.04.13
 * Time: 16:55
 */
package ru.teachbase.assets.images {
public class PanelPlaceholder {
    [Embed(source="/images/panel.png")]
    private static const PanelPlaceholder:Class;

    public static function create():Object{
        return new PanelPlaceholder();
    }
}
}
