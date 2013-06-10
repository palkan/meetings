package ru.teachbase.utils.geom
{
import flash.geom.Point;

public function angleAB(a:Point, b:Point):Number
	{
		var X:Number;
		var Y:Number;
		X = b.x - a.x;
		Y = b.y- a.y;
		
		if(X == 0)
		{
			if(Y >= 0)
				return Math.PI;
			else
				return 0;
		}
		else
		{
			if(X > 0)
				return Math.atan(Y / X) + Math.PI * 0.5;
			else if(Y >= 0)
				return Math.atan(Y / X) + Math.PI * 1.5;
			else
				return Math.atan(Y / X) - Math.PI * 0.5;
		}
	}
}