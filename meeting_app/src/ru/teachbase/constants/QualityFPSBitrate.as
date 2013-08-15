/**
 * User: palkan
 * Date: 8/14/13
 * Time: 2:03 PM
 */
package ru.teachbase.constants {
public class QualityFPSBitrate {

    private static const fps:Array = [15,10,6,2];

    private static const hi_bitrates:Array = [700, 575, 450, 300];

    private static const med_bitrates:Array = [300, 250, 180, 150];

    private static const low_bitrates:Array = [180, 100, 80, 65];

    private static const q2b:Array = [hi_bitrates, med_bitrates, low_bitrates];

    private static const qualities:Array = [PublishQuality.HIGH, PublishQuality.MEDIUM, PublishQuality.LOW];


    /**
     *
     * Return max available fps by bitrate and qualityId.
     *
     *
     * @param bitrate
     * @param quality
     * @return
     */


    public static function fpsByBitrateAndQuality(bitrate:Number, quality:String):int{

        if(qualities.indexOf(quality) < 0) return 0;

        const q:Array = q2b[qualities.indexOf(quality)];

        var i:int = 0;
        const size:int = q.length;

        for(i;i<size;i++){
            if(q[i] < bitrate) break;
        }

        return fps[i];

    }

}
}
