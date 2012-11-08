package
{
	import net.flashpunk.*;
	import net.flashpunk.graphics.*;
	import net.flashpunk.masks.*;
	import net.flashpunk.utils.*;
	
	import flash.display.*;
	
	public class Pushable extends Entity
	{
		public var moving:Boolean;
		
		public function Pushable (data:BitmapData)
		{
			graphic = new Image(data);
			mask = new Pixelmask(data);
			
			type = "solid";
			
			active = false;
		}
		
		public function getPushList (dx:int, dy:int): Array
		{
			if (! active) return null;
			
			moving = true;
			
			var allOtherCollides:Array = [];
			
			var thisCollides:Array = [];
			
			collideInto("solid", x+dx, y+dy, thisCollides);
			
			for each (var e:Pushable in thisCollides) {
				if (e.moving) continue;
				
				var thatCollides:Array = e.getPushList(dx, dy);
				
				if (! thatCollides) return null;
				
				allOtherCollides.push(thatCollides);
			}
			
			thisCollides.push(this);
			
			for each (thatCollides in allOtherCollides) {
				for each (e in thatCollides) {
					if (thisCollides.indexOf(e) == -1) {
						thisCollides.push(e);
					}
				}
			}
			
			return thisCollides;
		}
		
		public function move (dx:int, dy:int): void
		{
			var wall:Pushable = collide("solid", x+dx, y+dy) as Pushable;
			
			if (wall && wall != this) {
				wall.move(dx, dy);
			}
			
			x += dx;
			y += dy;
		}
	}
}

