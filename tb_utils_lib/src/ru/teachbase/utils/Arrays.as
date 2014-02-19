/**
 * User: palkan
 * Date: 8/9/13
 * Time: 2:06 PM
 */
package ru.teachbase.utils {

/**
 *
 * Some static function over Arrays.
 *
 */


public class Arrays {


    /**
     * Return random element from Array
     * @param arr
     * @return
     */


    public static function sample(arr:Array):*{

        if(!arr || !arr.length) return null;

        var buf:Array = arr.slice();

        buf.sort(function (...args){ return (Math.random() - .5);});

        return buf[0];

    }


    /**
     * Return sum of elements of numbers array.
     * @param arr
     */

    public static function sum(arr:Array):Number {

        const size:int = arr.length;
        var i:int = 0;

        var acc:Number = 0;

        for (i; i < size; i++)  acc+=arr[i];

        return acc;

    }

    /**
     *
     * @param arr
     * @return
     */



    public static function average(arr:Array):Number{

       return sum(arr)/arr.length;
    }


    /**
     *
     * Receive array of objects and key name, return array of values of this key.
     *
     * @param str
     * @param arr
     * @return
     */

    public static function key(keyName:String,arr:Array):Array{
       return arr.map(__key(keyName));
    }

    private static function __key(name:String):Function{

        return function(obj:Object,...args):*{ return obj[name];};

    }



}

}
