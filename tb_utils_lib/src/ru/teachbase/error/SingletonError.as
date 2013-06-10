/**
 * User: palkan
 * Date: 5/28/13
 * Time: 10:36 AM
 */
package ru.teachbase.error {
import flash.errors.IllegalOperationError;

public class SingletonError extends IllegalOperationError{
    public function SingletonError(){
        super("Trying to reinitiliaze singleton");
    }
}
}
