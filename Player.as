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
		
		public var canMove:Boolean = true;
		
		public var moveQueue:Array = [];
		
		public var sprite:Spritemap;
		
		public var direction:String;
		
		public function Player (_x:int, _y:int, c:uint)
		{
			x = _x;
			y = _y;
			
			sprite = new Spritemap(Gfx, 7, 7);
			sprite.relative = false;
			
			var framesPerDirection:int = 10;
			
			var dirs:Array = ["down", "up", "left", "right"];
			
			for (var i:int = 0; i < dirs.length; i++) {
				var dirString:String = dirs[i];
				sprite.add(dirString, [i*framesPerDirection], 0.1);
				sprite.add("push" + dirString, [i*framesPerDirection + 5], 0.1);
				
				sprite.add("walk" + dirString,
					FP.frames(i*framesPerDirection + 1, i*framesPerDirection + 4),
					0.25);
				sprite.add("pushmove" + dirString,
					FP.frames(i*framesPerDirection + 6, i*framesPerDirection + 9),
					0.25);
			}
			
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
		
		private function moveDone (): void
		{
			canMove = true;
			sprite.play(direction);
			direction = null;
		}
		
		public override function update (): void
		{
			var checkpoint:Entity = collide("checkpoint", x, y);
			
			if (checkpoint) {
				Level(world).hitCheckpoint(checkpoint);
			}
			
			if (Main.debugMode && Input.pressed(Key.SPACE)) {
				collidable = ! collidable;
			}
			
			if (Input.pressed(Key.RIGHT)) moveQueue.push(Key.RIGHT);
			if (Input.pressed(Key.LEFT)) moveQueue.push(Key.LEFT);
			if (Input.pressed(Key.UP)) moveQueue.push(Key.UP);
			if (Input.pressed(Key.DOWN)) moveQueue.push(Key.DOWN);
			
			if (! canMove) return;
			
			var dx:int;
			var dy:int;
			
			if (moveQueue.length) {
				var key:uint = moveQueue.shift();
				
				dx = int(key == Key.RIGHT) - int(key == Key.LEFT);
				dy = int(key == Key.DOWN) - int(key == Key.UP);
			} else {
				dx = int(Input.check(Key.RIGHT)) - int(Input.check(Key.LEFT));
				dy = int(Input.check(Key.DOWN)) - int(Input.check(Key.UP));
				
				if ((! dx && ! dy) || (dx && dy)) {
					if (direction) {
						sprite.play(direction);
						direction = null;
					}
					return;
				}
			}
			
			var newMove:Boolean = (direction == null);
			
			if (dx < 0) direction = "left";
			else if (dx > 0) direction = "right";
			else if (dy < 0) direction = "up";
			else if (dy > 0) direction = "down";
			
			sprite.play("push" + direction);
			
			var wall:Pushable;
			var currentFloor:Entity;
			
			if (newMove) Level.clearFeedback();
			
			if (collidable && collide("lava", x+dx, y+dy) && ! collide("floor", x+dx, y+dy)) {
				wall = collide("solid", x+dx, y+dy) as Pushable;
				
				if (wall) {
					currentFloor = collide("floor", x, y);
					
					if (currentFloor && currentFloor != wall.collide("floor", wall.x+dx, wall.y+dy)) {
						currentFloor = null;
					}
					
					if (newMove && ! currentFloor) {
						Level.feedback.setPixel32(x+dx, y+dy, Level.lavaColor);
						Level.updateFeedback(true);
					}
				}
				return;
			}
			
			var pushing:Boolean = false;
			
			wall = collide("solid", x+dx, y+dy) as Pushable;
			
			var tweenTime:int = 15;
			
			if (collidable && wall) {
				var pushList:Array = wall.getPushList(dx, dy);
				
				if (! pushList) {
					if (newMove) Level.updateFeedback();
					return;
				}
				
				currentFloor = collide("floor", x, y);
				
				if (currentFloor && pushList.indexOf(currentFloor) != -1) {
					return;
				}
				
				var floors:Array = [];
				
				var e:Pushable;
				
				for each (e in pushList) {
					FP.tween(e, {x: e.x+dx, y:e.y+dy}, tweenTime, {tweener: FP.tweener});
					e.moving = false;
				}
				
				pushing = true;
			}
			
			canMove = false;
			
			if (! pushing) tweenTime = 10;
			
			FP.tween(this, {x: x+dx, y:y+dy}, tweenTime, {tweener: FP.tweener, complete: moveDone});
			
			sprite.play((pushing ? "pushmove" : "walk") + direction);
			
			Audio.playNote();
		}
	}
}

