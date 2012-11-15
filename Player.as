package
{
	import net.flashpunk.*;
	import net.flashpunk.graphics.*;
	import net.flashpunk.masks.*;
	import net.flashpunk.utils.*;
	
	import flash.display.*;
	
	public class Player extends Entity
	{
		[Embed(source="images/player.png")] public static const Gfx: Class;
		
		public var moveCounter:int = 0;
		
		public var sprite:Spritemap;
		
		public var direction:String = "down";
		
		public function Player (_x:int, _y:int, c:uint)
		{
			x = _x;
			y = _y;
			
			sprite = new Spritemap(Gfx, 7, 7);
			sprite.relative = false;
			
			var framesPerDirection:int = 2;
			
			sprite.add("down",  [0*framesPerDirection], 0.1);
			sprite.add("up",    [1*framesPerDirection], 0.1);
			sprite.add("left",  [2*framesPerDirection], 0.1);
			sprite.add("right", [3*framesPerDirection], 0.1);
			
			sprite.add("pushdown",  [0*framesPerDirection + 1], 0.1);
			sprite.add("pushup",    [1*framesPerDirection + 1], 0.1);
			sprite.add("pushleft",  [2*framesPerDirection + 1], 0.1);
			sprite.add("pushright", [3*framesPerDirection + 1], 0.1);
			
			graphic = sprite;
			
			width = 1;
			height = 1;
			
			visible = false;
		}
		
		public override function render (): void
		{
			graphic.x = x*Main.TW-1;
			graphic.y = y*Main.TW-1;
			super.render();
		}
		
		public override function update (): void
		{
			if (Main.debugMode && Input.pressed(Key.SPACE)) {
				collidable = ! collidable;
				moveCounter = 0;
			}
			
			var dx:int = int(Input.pressed(Key.RIGHT)) - int(Input.pressed(Key.LEFT));
			
			if (! dx) {
				var dy:int = int(Input.pressed(Key.DOWN)) - int(Input.pressed(Key.UP));
			}
			
			if (!dx && ! dy) {
				dx = int(Input.check(Key.RIGHT)) - int(Input.check(Key.LEFT));
				dy = int(Input.check(Key.DOWN)) - int(Input.check(Key.UP));
				
				if ((! dx && ! dy) || (dx && dy)) {
					sprite.play(direction);
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
			
			if (dx < 0) direction = "left";
			else if (dx > 0) direction = "right";
			else if (dy < 0) direction = "up";
			else if (dy > 0) direction = "down";
			
			sprite.play("push" + direction);
			
			var wall:Pushable;
			var currentFloor:Entity;
			
			Level.clearFeedback();
			
			if (collidable && collide("lava", x+dx, y+dy) && ! collide("floor", x+dx, y+dy)) {
				wall = collide("solid", x+dx, y+dy) as Pushable;
				
				if (wall) {
					currentFloor = collide("floor", x, y);
					
					if (currentFloor && currentFloor != wall.collide("floor", wall.x+dx, wall.y+dy)) {
						currentFloor = null;
					}
					
					if (! currentFloor) {
						Level.feedback.setPixel32(x+dx, y+dy, Level.lavaColor);
						Level.updateFeedback(true);
					}
				}
				moveCounter = -1000000;
				return;
			}
			
			var pushing:Boolean = false;
			
			wall = collide("solid", x+dx, y+dy) as Pushable;
			
			if (collidable && wall) {
				var pushList:Array = wall.getPushList(dx, dy);
				
				if (! pushList) {
					Level.updateFeedback();
					moveCounter = -1000000;
					return;
				}
				
				currentFloor = collide("floor", x, y);
				
				if (currentFloor && pushList.indexOf(currentFloor) != -1) {
					return;
				}
				
				var floors:Array = [];
				
				var e:Pushable;
				
				for each (e in pushList) {
					e.x += dx;
					e.y += dy;
					e.moving = false;
				}
				
				pushing = true;
			}
			
			x += dx;
			y += dy;
			
			if (! pushing) sprite.play(direction);
			
			var checkpoint:Entity = collide("checkpoint", x, y);
			
			if (checkpoint) {
				Level(world).hitCheckpoint(checkpoint);
			}
			
			Audio.playNote();
		}
	}
}

