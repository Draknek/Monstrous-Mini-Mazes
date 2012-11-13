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
		
		public var wall:Image;
		public var ceiling:Image;
		
		public static var colorCanMove:uint = 0xFFEEEEEE;
		public static var colorNoMove:uint = 0xFF202020;
		
		public function Pushable (_data:BitmapData, _type:String = "solid")
		{
			if (!_type) _type = "solid";
			
			this.data = _data;
			this.type = _type;
			
			mask = new Pixelmask(data);
			
			bounds = data.getColorBoundsRect(0xFF000000, 0xFF000000);
			
			var wallBitmap:BitmapData = new BitmapData(bounds.width*Main.TW, bounds.height*Main.TW+3, true, 0x0);
			var ceilingBitmap:BitmapData = new BitmapData(bounds.width*Main.TW, bounds.height*Main.TW+3, true, 0x0);
			
			for (var i:int = 0; i < bounds.width; i++) {
				for (var j:int = 0; j < bounds.height; j++) {
					var ix:int = bounds.x + i;
					var iy:int = bounds.y + j;
					
					var c:uint = data.getPixel32(ix, iy);
					
					if ((c & 0xFF000000) == 0x0) continue;
					
					if (type == "floor") {
					
					} else {
						FP.rect.width = Main.TW;
						FP.rect.height = Main.TW;
						FP.rect.x = i*Main.TW;
						FP.rect.y = j*Main.TW;
						
						ceilingBitmap.fillRect(FP.rect, colorNoMove);
						
						FP.rect.width -= 2;
						FP.rect.height -= 2;
						FP.rect.x += 1;
						FP.rect.y += 1;
						
						ceilingBitmap.fillRect(FP.rect, c);
						
						FP.rect.width = Main.TW;
						FP.rect.height = 3;
						FP.rect.x = i*Main.TW;
						FP.rect.y = (j+1)*Main.TW;
						
						wallBitmap.fillRect(FP.rect, c);
					}
				}
			}
			
			wall = new Image(wallBitmap);
			ceiling = new Image(ceilingBitmap);
			
			wall.relative = false;
			ceiling.relative = false;
			
			active = (type == "floor");
			
			visible = false;
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
		
		public function renderWall(): void
		{
			graphic = wall;
			graphic.x = (x+bounds.x)*Main.TW;
			graphic.y = (y+bounds.y)*Main.TW;
			super.render();
		}
		
		public function renderCeiling(): void
		{
			graphic = ceiling;
			graphic.x = (x+bounds.x)*Main.TW;
			graphic.y = (y+bounds.y)*Main.TW;
			super.render();
		}
		
		private static var rect:Rectangle = new Rectangle;
	}
}

