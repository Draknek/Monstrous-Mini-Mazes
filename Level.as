package
{
	import net.flashpunk.*;
	import net.flashpunk.graphics.*;
	import net.flashpunk.masks.*;
	import net.flashpunk.utils.*;
	
	import flash.display.*;
	
	public class Level extends World
	{
		[Embed(source="level.png")] public static const MapGfx: Class;
		
		public var walls:Array;
		
		public function Level ()
		{
			var data:BitmapData = FP.getBitmap(MapGfx);
			
			var floorColor:uint = data.getPixel(0,0);
			var playerColor:uint = data.getPixel(1,0);
			var checkpointColor:uint = data.getPixel(2,0);
			
			var c:uint = data.getPixel(0,1);
			
			data.setPixel(0,0,c);
			data.setPixel(1,0,c);
			data.setPixel(2,0,c);
			
			walls = [];
			var lookup:Object = [];
			
			var entityData:Object;
			var maskData:BitmapData;
			
			for (var i:int = 0; i < data.width; i++) {
				for (var j:int = 0; j < data.height; j++) {
					c = data.getPixel(i, j);
					
					if (c == floorColor) {
						continue;
					}
					else if (c == playerColor) {
						add(new Player(i, j, c));
						continue;
					}
					else if (c == checkpointColor) {
						add(new Checkpoint(i, j, c));
						continue;
					}
					
					if (! lookup[c]) {
						maskData = new BitmapData(data.width, data.height, true, 0x0);
						lookup[c] = maskData;
						walls.push(maskData);
					}
					
					lookup[c].setPixel32(i, j, 0xFF000000 | c);
				}
			}
			
			walls.reverse();
			
			for (i = 0; i < walls.length; i++) {
				maskData = walls[i];
				var wall:Pushable = new Pushable(maskData);
				add(wall);
				walls[i] = wall;
			}
			
		}
		
		public override function update (): void
		{
			for each (var wall:Pushable in walls) {
				wall.moving = false;
			}
			super.update();
		}
		
		public override function render (): void
		{
			super.render();
		}
	}
}

