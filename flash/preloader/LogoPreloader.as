package  {
	
	import flash.display.MovieClip;
	import mx.flash.UIMovieClip;
	
	
	public class LogoPreloader extends UIMovieClip {
		
		
		public var _mask:MovieClip;
		public var logo:MovieClip;
		
		public function LogoPreloader() {
			
		}
		
		
		public function loadProgress(value:Number):void{
			
			
			_mask.x =  _mask.width * (1 - value);
			
			
		}
		
		
	}
	
}
