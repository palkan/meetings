package ru.teachbase.utils {
import flash.errors.EOFError;
import flash.utils.ByteArray;

import ru.teachbase.model.TBSPacket;

/**
 *
 * Read Teachbase binary stream files (tbs).
 *
 * Stream structure:
 *
 *  << packet|packet|... >>
 *
 * Packet structure:
 *
 *  << timestamp:4|size:4|amf3_data:_ >>
 *
 */

public class TBSReader {


    private static const HEADER_SIZE:int = 8;

    /**
     *
     * Read binary data and returns [].<TBSPacket>
     *
     * @param bin
     * @return
     */


    public static function read(bin:ByteArray):Vector.<TBSPacket>{

        if(!bin) return null;

        const size:Number = bin.bytesAvailable;

        const result:Vector.<TBSPacket> = new <TBSPacket>[];

        var eof:Boolean = false;

        bin.position = 0;

        var data:TBSPacket;

        while(!eof){

            data = readPacket(bin);

            if(data) result.push(data);
            else eof = true;

        }

        return result;

    }


    /**
     *
     * Read one packet from binary and return.
     *
     * Binary position shifts according to packet size.
     *
     * @throw EOError When AMF is wrong or provided size is wrong.
     *
     * @param bin
     * @return
     *
     */

    public static function readPacket(bin:ByteArray):TBSPacket{

        if(!bin || bin.bytesAvailable < HEADER_SIZE) return null;

        const ts:Number = bin.readUnsignedInt();

        const psize:Number = bin.readUnsignedInt();

        if(bin.bytesAvailable < psize) throw new EOFError("Wrong size. Not enough bytes.");

        const buffer:ByteArray = new ByteArray();

        bin.readBytes(buffer,0,psize);

        const data:* = buffer.readObject();

        return new TBSPacket(ts,data);

    }


}
}
