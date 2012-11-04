package
{
	import net.flashpunk.*;
	import net.flashpunk.graphics.*;
	import net.flashpunk.masks.*;
	import net.flashpunk.utils.*;
	
	import flash.display.*;
	
	public class Player extends Entity
	{
		public function Player (_x:int, _y:int, c:uint)
		{
			x = _x;
			y = _y;
			
			graphic = new Stamp(new BitmapData(1, 1, false, c));
			
			width = 1;
			height = 1;
		}
		
		public override function update (): void
		{
			var dx:int = int(Input.pressed(Key.RIGHT)) - int(Input.pressed(Key.LEFT));
			
			if (! dx) {
				var dy:int = int(Input.pressed(Key.DOWN)) - int(Input.pressed(Key.UP));
			}
			
			if (!dx && ! dy) return;
			
			var wall:Pushable = collide("solid", x+dx, y+dy) as Pushable;
			
			if (wall) {
				var pushList:Array = wall.getPushList(dx, dy);
				
				if (! pushList) return;
				
				for each (var e:Pushable in pushList) {
					e.x += dx;
					e.y += dy;
					e.moving = false;
				}
			}
			
			x += dx;
			y += dy;
			
			var checkpoint:Entity = collide("checkpoint", x, y);
			
			if (checkpoint) {
				world.remove(checkpoint);
				
				for each (e in Level(world).walls) {
					if (e.active) continue;
					e.active = true;
					break;
				}
			}
		}
	}
}

