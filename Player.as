package
{
	import net.flashpunk.*;
	import net.flashpunk.graphics.*;
	import net.flashpunk.masks.*;
	import net.flashpunk.utils.*;
	
	import flash.display.*;
	
	public class Player extends Entity
	{
		public var moveCounter:int = 0;
		
		public function Player (_x:int, _y:int, c:uint)
		{
			x = _x;
			y = _y;
			
			graphic = new Stamp(new BitmapData(1, 1, false, c));
			
			width = 1;
			height = 1;
			
			layer = -1;
		}
		
		public override function update (): void
		{
			if (Input.pressed(Key.SPACE)) {
				collidable = ! collidable;
			}
			
			var dx:int = int(Input.pressed(Key.RIGHT)) - int(Input.pressed(Key.LEFT));
			
			if (! dx) {
				var dy:int = int(Input.pressed(Key.DOWN)) - int(Input.pressed(Key.UP));
			}
			
			if (!dx && ! dy) {
				dx = int(Input.check(Key.RIGHT)) - int(Input.check(Key.LEFT));
				dy = int(Input.check(Key.DOWN)) - int(Input.check(Key.UP));
				
				if ((! dx && ! dy) || (dx && dy)) {
					moveCounter = 0;
					return;
				}
				
				moveCounter++;
				
				if (moveCounter < 10) {
					return;
				}
				
				moveCounter -= 10;
			} else {
				moveCounter = 0;
			}
			
			Level.clearFeedback();
			
			if (collidable && collide("lava", x+dx, y+dy)) {
				Level.feedback.setPixel32(x+dx, y+dy, Level.lavaColor);
				Level.updateFeedback();
				return;
			}
			
			var wall:Pushable = collide("solid", x+dx, y+dy) as Pushable;
			
			if (! collidable) wall = null;
			
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
				Level(world).hitCheckpoint(checkpoint);
			}
			
			Audio.playNote();
		}
	}
}

