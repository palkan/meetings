package ru.teachbase.utils
{
import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.MovieClip;
import flash.display.Shape;
import flash.geom.Point;
import flash.text.TextField;
import flash.text.TextSnapshot;

public class StaticTextUtil
	{
		private var _charArray:Array;
		private var _snapShot:TextSnapshot;
		private var _contReference:MovieClip;
		private var _hightlightContainer:Shape = new Shape();
		
		public function StaticTextUtil()
		{
		}
		
		public function init(clip:MovieClip):void{
			_contReference = clip;
			parseMoveClip(clip);
			_contReference.addChild(_hightlightContainer);
		}
		
		public function parseMoveClip(clip:DisplayObject, depth:int = 0):Boolean{
			var cont:DisplayObjectContainer;
			
			if (clip is TextField) {

			}
			
			if (clip is DisplayObjectContainer){
				cont = clip as DisplayObjectContainer;
				_snapShot = cont.textSnapshot;
				//Assume that all staticText is inside one movie
				if (_snapShot.charCount >0 ){
					if (_charArray == null) {
						_charArray = _snapShot.getTextRunInfo(0,_snapShot.charCount);
					}
					return true;
				}
			}else{
				return false;
			}
			
			if (cont != null || cont.numChildren > 0) {
				for (var i:int;i< cont.numChildren; i++) {
					 if (parseMoveClip(cont.getChildAt(i),depth +1)){
						 break;
					}
				}	
			}
			return true;
		}
		
		public function getNearestCharOld(p:Point, radius:Number = 0):String{
			if (_charArray == null || _charArray.length == 0) {return "null"}
			var minDistance:Number;
			var num:int;

			for (var i:int = 0; i< _charArray.length; i++) {
				var xL:Number = p.x - _charArray[i].matrix_tx;
				var yL:Number = p.y - _charArray[i].matrix_ty;
				var l:Number = Math.sqrt(xL*xL + yL*yL);
				if (i == 0 || l < minDistance) {
					minDistance = l;
					num = i;
				}
			}
			
			return _snapShot.getText(num,num);
		}
		
		public function getNearestChar(p:Point,radius:Number = 0):String{
			const i:int = _snapShot.hitTestTextNearPos(p.x,p.y);
			return _snapShot.getText(i,i);
		}
		
		//if hitTest doesn't work
		public function getTextByDeltaOld(start:Point, end:Point):String {
			var res:String = "";
			var _resArr:Array = new Array();
			
			const inaccuracy:Number= 5;
			
			//TODO: direction
			for (var i:int = 0 ; i< _charArray.length; i++){
				if (_charArray[i].matrix_tx >= start.x-inaccuracy && 
					_charArray[i].matrix_ty >= start.y - _charArray[i].height && 
					_charArray[i].matrix_tx <= end.x && 
					_charArray[i].matrix_ty <= end.y+inaccuracy )	{
						res += 	_snapShot.getText(i,i);	
						_resArr.push(_charArray[i]);
				}else if (_charArray[i].matrix_tx > end.x && _charArray[i].matrix_ty > start.y){ 
					//stop checking
					break;
				}
			}

			if (_resArr.length >0) {
				drawPath(_resArr);
			}
			
			return res;
		}
		
		//new version, with HitTest
		public function getTextByDelta(start:Point, end:Point):String {
			const startIndex:int = _snapShot.hitTestTextNearPos(start.x,start.y,50);
			const endIndex:int = _snapShot.hitTestTextNearPos(end.x,end.y,50);
			var resArr:Array;
			var resText:String = "";
			if(startIndex <0 || endIndex <0) {
				return "false";
			}
			
			if (startIndex < endIndex){
				resArr = _charArray.slice(startIndex,endIndex);
				resText = _snapShot.getText(startIndex,endIndex);
			}else{
				resArr = _charArray.slice(endIndex,startIndex);
				resText = _snapShot.getText(endIndex,startIndex);
			}
			
			if (resArr.length > 0) {
				drawPath(resArr);
			}
			
			return resText;
		}
		
		public function clearHightlight():void{
			_hightlightContainer.graphics.clear();
		}
		
		private function drawPath(charArr:Array):void{
			const pathCommands:Vector.<int> = new Vector.<int>();
			const pathData:Vector.<Number> = new Vector.<Number>();
			const lineHeight:Number = charArr[0].height;
			pathCommands.push(1);
			pathData.push(charArr[0].matrix_tx);
			pathData.push(charArr[0].matrix_ty-charArr[0].height/2);
			
			var prevY:Number = charArr[0].matrix_ty;
			var prevX:Number = charArr[0].matrix_tx;
			var stringHeight:Number = charArr[0].height;
			
			for (var i:int=0;i<charArr.length;i++){
				
				var toX:Number = charArr[i].matrix_tx;
				var toY:Number = charArr[i].matrix_ty;
				
				if (toY > prevY + stringHeight) {
					pathCommands.push(1);
					prevY = toY;
					stringHeight = charArr[i].height;
				}else if(toY < prevY - stringHeight) {
					prevY = toY;
					pathCommands.push(1);
					stringHeight = charArr[i].height;
				}else{
					toY = prevY;
					pathCommands.push(2);
				}
					
				pathData.push(toX);
				pathData.push(toY-charArr[i].height/2);
				
				
				prevX = toX;
			}
			
			_hightlightContainer.graphics.clear();
			_hightlightContainer.graphics.lineStyle(lineHeight,0xFF0000,.5,false,"normal","square");
			_hightlightContainer.graphics.drawPath(pathCommands,pathData, "nonZero");
		}
		
		public function dispose():void{
			_charArray = null;	
			_snapShot = null;
			_hightlightContainer = null;
		}
	}
}