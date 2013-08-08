package ru.teachbase.utils.extensions
{
import flash.errors.IllegalOperationError;
import flash.utils.Dictionary;
import flash.utils.Proxy;
import flash.utils.flash_proxy;

import ru.teachbase.utils.interfaces.IDisposable;

use namespace flash_proxy;

	/**
     *
     * Object which has every field as Dictionary of Functions
     *
     *
     *
	 * @author Teachbase (created: May 28, 2013)
	 */
	public dynamic class FuncObject  extends Proxy implements IDisposable
	{
		private const storage:Object = {};
        private var _disposed:Boolean = false;

		//------------ constructor ------------//
		
		public function FuncObject()
		{

		}
		
		//------------ initialize ------------//
		
		//--------------- ctrl ---------------//

        public function clear():void{
            for(var key:* in storage) delete storage[key];
        }



        public function dispose():void{
             clear();
            _disposed = true;
        }

		
		override flash_proxy function callProperty(name:*, ...parameters):*
		{
            if(!storage.hasOwnProperty(name))
                return false;

            (storage[name] as PolyFunction).fun.apply(null,parameters);
		}

		override flash_proxy function deleteProperty(name:*):Boolean
		{
			if(!storage.hasOwnProperty(name))
				return false;

			delete storage[name];

			return true;
		}


        public function deleteFromProperty(name:*,key:*):Boolean{
            if(!storage.hasOwnProperty(name))
                return false;

            if(!storage[name].remove(key))  delete storage[name];

            return true;
        }

		override flash_proxy function setProperty(name:*, value:*):void
		{
            if(!storage.hasOwnProperty(name)) storage[name] = new PolyFunction(name);
			storage[name].add(value);
		}



		override flash_proxy function getProperty(name:*):*
		{

			if(!storage.hasOwnProperty(name)) return false;

            return storage[name].fun;
		}

		override flash_proxy function hasProperty(name:*):Boolean
		{
			return storage.hasOwnProperty(name);
		}




		override flash_proxy function getDescendants(name:*):*
		{
			throw new IllegalOperationError('this feature is not supported yet');
			return null;
		}

		override flash_proxy function nextName(index:int):String
		{
			throw new IllegalOperationError('this feature is not supported yet');
			return super.flash_proxy::nextName(index);
		}

		override flash_proxy function nextNameIndex(index:int):int
		{
			throw new IllegalOperationError('this feature is not supported yet');
			return super.flash_proxy::nextNameIndex(index);
		}

		override flash_proxy function nextValue(index:int):*
		{
			throw new IllegalOperationError('this feature is not supported yet');
			return super.flash_proxy::nextValue(index);
		}

		//------------ get / set -------------//

		//------- handlers / callbacks -------//

        public function get disposed():Boolean {
            return _disposed;
        }
    }
}


internal class PolyFunction{

    private var _name:String;

    private const _functions:Vector.<Function> = new <Function>[];

    private var _cached:Function;


    public function PolyFunction(name:String){
        _name = name;
    }


    public function add(f:Function):uint{
        if(_functions.indexOf(f) < 0) _functions.push(f), _cached = null;

        return length;
    }

    public function remove(f:Function):uint{
        var i:int;
        if((i = _functions.indexOf(f)) > -1) _functions.splice(i,1), _cached = null;

        return length;
    }


    /**
     *
     * Get poly function closure
     *
     */

    public function get fun():Function{

        if(!_cached){

            const size:uint = length;

            if(!size) return null;

            if(size === 1) return _functions[0];


            const closure:Object = function (...rest:Array):*
            {
                for(var i:uint = 0; i < size; i++) _functions[i].apply(null,rest);
            };

            closure.fname = _name;

            _cached = closure as Function;
        }
        return _cached;
    }


    public function get length():uint{
        return _functions.length;
    }


}