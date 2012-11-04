package
{
	import net.flashpunk.*;
	import net.flashpunk.graphics.*;
	import net.flashpunk.masks.*;
	import net.flashpunk.utils.*;
	
	import flash.display.*;
	
	public class Checkpoint extends Entity
	{
		public function Checkpoint (_x:int, _y:int, c:uint)
		{
			x = _x;
			y = _y;
			
			graphic = new Stamp(new BitmapData(1, 1, false, c));
			
			width = 1;
			height = 1;
			
			type = "checkpoint";
		}
	}
}

