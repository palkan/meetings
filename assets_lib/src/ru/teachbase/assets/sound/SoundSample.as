/**
 * User: VOVA
 * Date: 25.04.13
 * Time: 17:00
 */
package ru.teachbase.assets.sound {
public class SoundSample {

    [Embed(source="/sound/clip.mp3")]
    private static const _soundClass:Class;

    public static function create(){
        return new _soundClass();
    }
}
}
