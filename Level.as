package
{
	import net.flashpunk.*;
	import net.flashpunk.graphics.*;
	import net.flashpunk.masks.*;
	import net.flashpunk.utils.*;
	
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	import flash.net.*;
	
	public class Level extends World
	{
		[Embed(source="level.png")] public static const MapGfx: Class;
		
		public static var levelData:BitmapData;
		
		public var walls:Array;
		
		public function Level ()
		{
			checkForNewLevel();
			
			var data:BitmapData = levelData;
			
			var floorColor:uint = data.getPixel(0,0);
			var playerColor:uint = data.getPixel(1,0);
			var checkpointColor:uint = data.getPixel(2,0);
			var replaceColor:uint = data.getPixel(0,1);
			
			walls = [];
			var lookup:Object = [];
			
			var entityData:Object;
			var maskData:BitmapData;
			
			var c:uint;
			
			for (var i:int = 0; i < data.width; i++) {
				for (var j:int = 0; j < data.height; j++) {
					c = data.getPixel(i, j);
					
					if (i <= 2 && j == 0) {
						c = replaceColor;
					}
					
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
		
		private static var loading:Boolean = false;
		
		public function checkForNewLevel (): void
		{
			if (! levelData) levelData = FP.getBitmap(MapGfx);
			
			if (loading) {
				loading = false;
				return;
			}
			
			var loader:Loader = new Loader();
			
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, function (e:Event):void {
				try {
					levelData = Bitmap(loader.content).bitmapData;
				} catch (error:Error) {}
				
				FP.world = new Level;
			});
			
			loader.load(new URLRequest("level.png"));
			
			loading = true;
		}
		
		public function refocus (instant:Boolean = false): void
		{
			var e:Pushable;
			
			for each (e in walls) {
				if (! e.active) break;
			}
			
			if (! e) return;
			
			var bitmap:BitmapData = Pixelmask(e.mask).data;
			
			var rect:Rectangle = bitmap.getColorBoundsRect(0xFF000000, 0xFF000000);
			
			rect.x += 1;
			rect.y += 1;
			
			rect.width -= 2;
			rect.height -= 2;
			
			var borderX:int = 16;
			var borderY:int;
			
			var scale:Number = (FP.stage.stageWidth - borderX*2) / rect.width;
			
			borderX = FP.stage.stageWidth - rect.width*scale;
			borderY = FP.stage.stageHeight - rect.height*scale;
			
			var screenX:int = - rect.x * scale + borderX/2;
			var screenY:int = - rect.y * scale + borderY/2;
			
			if (instant) {
				FP.screen.scale = scale;
				FP.screen.x = screenX;
				FP.screen.y = screenY;
			} else {
				var tweenTime:int = 32;
				
				FP.tween(FP.screen, {scale: scale, x: screenX, y: screenY}, tweenTime);
			}
		}
		
		public override function begin (): void
		{
			refocus(true);
		}
		
		public override function update (): void
		{
			if (Input.pressed(Key.R)) {
				checkForNewLevel();
				return;
			}
			
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

