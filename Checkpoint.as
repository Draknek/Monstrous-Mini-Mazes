package
{
	import net.flashpunk.*;
	import net.flashpunk.graphics.*;
	import net.flashpunk.masks.*;
	import net.flashpunk.utils.*;
	
	import flash.display.*;
	
	public class Checkpoint extends Entity
	{
		[Embed(source="images/checkpoint.png")] public static const Gfx: Class;
		
		public function Checkpoint (_x:int, _y:int, c:uint)
		{
			x = _x;
			y = _y;
			
			var sprite:Spritemap = new Spritemap(Gfx, 5, 5);
			sprite.relative = false;
			sprite.x = x*Main.TW;
			sprite.y = y*Main.TW;
			
			sprite.add("sparkle", FP.frames(0, sprite.frameCount - 1), 0.1);
			sprite.play("sparkle");
			
			graphic = sprite;
			
			width = 1;
			height = 1;
			
			type = "checkpoint";
			
			layer = -1;
		}
	}
}

