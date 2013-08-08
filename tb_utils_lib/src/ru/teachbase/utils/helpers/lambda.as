/**
 * User: palkan
 * Date: 8/7/13
 * Time: 1:00 PM
 */
package ru.teachbase.utils.helpers {

/**
 * Generate function closure.
 *
 * @param fun Function to call.
 * @param args Arguments to call the function with.
 *
 */

public function lambda(fun:Function,...args):Function {

    return function(){ fun.apply(null,args);};
}

}
