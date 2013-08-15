/**
 * User: palkan
 * Date: 8/9/13
 * Time: 1:50 PM
 */
package ru.teachbase.utils.data {
public dynamic class LimitArray extends Array{

    private var _limit:int = 0;

    public function LimitArray(limit:int = 0){
        _limit = limit;
        super();
    }

    public function add(el:*):uint{

        if(_limit && _limit<this.length+1) this.shift();

        return super.push(el);
    }


    public function get limit():int{
        return _limit;
    }

    public function set limit(value:int):void{
        _limit = value;

        if(!_limit) return;

        if(_limit < this.length) this.splice(0,this.length - _limit);
    }

}
}
