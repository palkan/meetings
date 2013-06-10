package ru.teachbase.behaviours
{
	
	/**
	 * @author Teachbase (created: Jan 25, 2012)
	 */
	public final class DragDirection
	{
		public static const RIGHT:uint = 1 << 0;
		public static const LEFT:uint = 1 << 1;
		public static const UP:uint = 1 << 2;
		public static const DOWN:uint = 1 << 3;
		
		public static const NO_DIRECTION:uint = 0;
		public static const HORIZONTAL:uint = RIGHT | LEFT;
		public static const VERTICAL:uint = UP | DOWN;
		public static const ORTHOGONAL:uint = RIGHT | LEFT | UP | DOWN;
		
		public static const ANY:uint = ORTHOGONAL | ORTHOGONAL;
		
		// sorted NUMERIC in binary
		private static const ALL:Array = [ANY, ORTHOGONAL, VERTICAL, HORIZONTAL, DOWN, UP, LEFT, RIGHT, NO_DIRECTION];
		
		public static function getNameByValue(value:uint):String
		{
			switch(value)
			{
				case(ANY):
				{
					return 'any';
					break;
				}
				
				case(LEFT):
				{
					return 'left';
					break;
				}
				
				case(RIGHT):
				{
					return 'right';
					break;
				}
				
				case(UP):
				{
					return 'up';
					break;
				}
				
				case(DOWN):
				{
					return 'down';
					break;
				}
				
				case(NO_DIRECTION):
				{
					return 'no direction';
					break;
				}
				
				case(HORIZONTAL):
				{
					return 'horizontal';
					break;
				}
				
				case(VERTICAL):
				{
					return 'vertical';
					break;
				}
				
				case(ORTHOGONAL):
				{
					return 'orthogonal';
					break;
				}
				
				// detect combo:
				case(LEFT | UP):
				{
					return 'left + up';
					break;
				}
				
				case(LEFT | DOWN):
				{
					return 'left + down';
					break;
				}
				
				case(RIGHT | UP):
				{
					return 'right + up';
					break;
				}
				
				case(RIGHT | DOWN):
				{
					return 'right + down';
					break;
				}
				
				
				default:
				{
					return 'unknown';
				}
			}
		}
		
		public static function getValueByAngle(radians:Number):uint
		{
			//TODO: optimize me!
			
			var result:uint = NO_DIRECTION;
			
			// move into range [-180 deg, +180 deg]
			while(radians < -Math.PI) radians += Math.PI * 2.0;
			while(radians >  Math.PI) radians -= Math.PI * 2.0;
			
			var degree:Number = radians * 180 / Math.PI;
			
			// move into range [+0 deg, +360 deg]
			degree < 0 && (degree += 360);
			
			// calc:
			(degree > 180 && degree < 360) && (result = result | LEFT);
			(degree > 0 && degree < 180) && (result = result | RIGHT);
			(degree > 270 || degree < 90) && (result = result | UP);
			(degree > 90 && degree < 270) && (result = result | DOWN);
			
			
			
			return result;
		}
		
		/**
		 * 
		 * @param a binary flags
		 * @param b binary flags
		 * @return a constains b
		 * 
		 */		
		public static function collisionAB(a:uint, b:uint):Boolean
		{
			for(var i:int; i < ALL.length; ++i)
			{
				//        OK                    EQ
				if((ALL[i] & a) && (ALL[i] & a) == (ALL[i] & b))
					return true;
			}
			
			return false;
		}
	}
}