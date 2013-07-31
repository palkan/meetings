/**
 * User: palkan
 * Date: 7/31/13
 * Time: 4:33 PM
 */
package ru.teachbase.utils.shortcuts {

/**
 *
 * Null-function is a function that accepting arbitrary number of arguments and do nothing.
 *
 * We need this function to fit the stupidness  of Responder, which cannot handle partial initiation.
 *
 * For example, if we write <code>new Responder(fun1,null)</code> we then can not check whether such responder has fault function or not. And we get exceptions...
 *
 * So, we use <code>new Responder(fun1,$dummy)</code> and we don't care about fault function anymore.
 *
 *
 */

    public function $null(...args) {
    }
}
