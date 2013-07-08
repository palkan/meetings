/**
 * User: palkan
 * Date: 5/30/13
 * Time: 1:06 PM
 */
package ru.teachbase.utils {
import flash.media.Microphone;
import flash.media.MicrophoneEnhancedMode;
import flash.media.MicrophoneEnhancedOptions;
import flash.media.SoundCodec;

public class MicrophoneUtils {

    /**
     * Get Microphone by id (or default)
     * @param id
     * @param enhanced  If <code>true</code> then trying to get enhanced Mic first and if fails - simple Mic
     * @return
     */

    public static function getMicrophone(id:int = -1, enhanced:Boolean = false):Microphone {

       var mic:Microphone = enhanced ? getEnhancedMic(id) : getSimpleMic(id);

       !mic && enhanced && (mic = getSimpleMic(id));

       return mic;

    }

    public static function configure(mic:Microphone,codec:String = SoundCodec.SPEEX, rate:int = 11, encodeQuality:int = 5, fpp:int = 2, gain:int = 80, silenceLevel:int = 0, loopback:Boolean = false):Microphone{
        mic.codec = codec;
        mic.rate = rate;
        mic.encodeQuality = encodeQuality;
        mic.framesPerPacket = fpp;
        mic.gain = gain;
        mic.setSilenceLevel(silenceLevel);
        mic.setLoopBack(loopback);
        return mic;
    }

    private static function getSimpleMic(id:int):Microphone{
        var mic:Microphone;
        mic = Microphone.getMicrophone(id);
        if (mic) {
            mic = Microphone.getMicrophone();
        }

        if (!mic) return null;
        mic.setUseEchoSuppression(true);
        return mic;
    }

    private static function getEnhancedMic(id:int):Microphone{
        var mic:Microphone;

        var options:MicrophoneEnhancedOptions = new MicrophoneEnhancedOptions();
        options.mode = MicrophoneEnhancedMode.FULL_DUPLEX;
        options.echoPath = 128;
        options.nonLinearProcessing = true;
        mic = Microphone.getEnhancedMicrophone(id);
        if (!mic) {
            mic = Microphone.getEnhancedMicrophone();
        }

        if (!mic) return null;

        mic.enhancedOptions = options;
        return mic;
    }
}
}
