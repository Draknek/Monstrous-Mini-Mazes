package
{
	import net.flashpunk.*;
	import net.flashpunk.graphics.*;
	import net.flashpunk.masks.*;
	import net.flashpunk.utils.*;
	
	import flash.display.*;
	import flash.geom.*;
	
	public class Pushable extends Entity
	{
		public var moving:Boolean;
		
		public var bounds:Rectangle;
		
		public var data:BitmapData;
		
		public function Pushable (_data:BitmapData)
		{
			this.data = _data;
			
			graphic = new Image(data);
			mask = new Pixelmask(data);
			
			bounds = data.getColorBoundsRect(0xFF000000, 0xFF000000);
			
			type = "solid";
			
			active = false;
		}
		
		public function getPushList (dx:int, dy:int): Array
		{
			if (! active) return null;
			
			moving = true;
			
			var hitSomething:Boolean = false;
			
			var allOtherCollides:Array = [];
			
			var thisCollides:Array = [];
			
			collideInto("solid", x+dx, y+dy, thisCollides);
			collideInto("floor", x+dx, y+dy, thisCollides);
			
			for each (var e:Pushable in thisCollides) {
				if (e.moving) continue;
				
				if (! e.active) {
					hitSomething = true;
					makeFeedback(e, dx, dy);
					continue;
				}
				
				var thatCollides:Array = e.getPushList(dx, dy);
				
				if (! thatCollides) {
					hitSomething = true;
					continue;
				}
				
				allOtherCollides.push(thatCollides);
			}
			
			if (hitSomething) return null;
			
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
		
		private function makeFeedback (that:Pushable, dx:int, dy:int):void
		{
			for (var i:int = 0; i < bounds.width; i++) {
				for (var j:int = 0; j < bounds.height; j++) {
					var ix:int = bounds.x + i;
					var iy:int = bounds.y + j;
					
					var c:uint = this.data.getPixel32(ix, iy);
					
					if ((c & 0xFF000000) == 0x0) continue;
					
					ix += this.x + dx - that.x;
					iy += this.y + dy - that.y;
					
					c = that.data.getPixel32(ix, iy);
					
					if ((c & 0xFF000000) == 0x0) continue;
					
					ix += that.x;
					iy += that.y;
					
					Level.feedback.setPixel32(ix, iy, 0xFFFFFFFF);
				}
			}
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

