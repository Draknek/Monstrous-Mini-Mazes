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
		
		public static var saveFile:Object;
		
		public var player:Player;
		public var movingFloor:Pushable;
		
		public static var feedback:BitmapData;
		public static var feedbackImage:Image;
		
		public static var floorColor:uint;
		public static var playerColor:uint;
		public static var checkpointColor:uint;
		public static var lavaColor:uint;
		public static var fakeLavaColor:uint;
		public static var movingFloorColor:uint;
		
		public var visibleBounds:Rectangle;
		
		public function Level ()
		{
			if (! saveFile) saveFile = {walls: [], checkpoints: []};
			
			checkForNewLevel();
			
			var data:BitmapData = levelData;
			
			floorColor = data.getPixel32(0,0);
			playerColor = data.getPixel32(1,0);
			checkpointColor = data.getPixel32(2,0);
			lavaColor = data.getPixel32(3,0);
			fakeLavaColor = data.getPixel32(4,0);
			movingFloorColor = data.getPixel32(5,0);
			
			var replaceColor:uint = data.getPixel32(0,1);
			
			walls = [];
			var lookup:Object = [];
			
			var entityData:Object;
			var maskData:BitmapData;
			
			var c:uint;
			
			var doublePixel:Boolean = false;
			
			for (var i:int = 0; i < data.width; i++) {
				for (var j:int = 0; j < data.height; j++) {
					c = data.getPixel32(i, j);
					
					if (i <= 10 && j == 0) {
						c = replaceColor;
					}
					
					if (c == fakeLavaColor) {
						if (doublePixel) {
							c = getColorAboveLava(data, i, j);
						} else {
							c = lavaColor;
						}
						
						doublePixel = ! doublePixel;
					}
					
					if (c == floorColor) {
						continue;
					}
					else if (c == playerColor) {
						player = new Player(i, j, c);
						add(player);
						continue;
					}
					else if (c == checkpointColor) {
						add(new Checkpoint(i, j, c));
						continue;
					}
					
					if (! lookup[c]) {
						maskData = new BitmapData(data.width, data.height, true, 0x0);
						lookup[c] = maskData;
						
						if (c != lavaColor && c != movingFloorColor) {
							walls.push(maskData);
						}
					}
					
					lookup[c].setPixel32(i, j, 0xFF000000 | c);
					
					if (doublePixel) {
						// Do it again...
						j--;
					}
				}
			}
			
			sortWalls();
			
			for (i = 0; i < walls.length; i++) {
				maskData = walls[i];
				var wall:Pushable = new Pushable(maskData);
				add(wall);
				walls[i] = wall;
			}
			
			var lava:Entity = new Entity;
			lava.layer = 2;
			lava.type = "lava";
			lava.graphic = new Stamp(lookup[lavaColor]);
			lava.mask = new Pixelmask(lookup[lavaColor]);
			
			add(lava);
			
			if (lookup[movingFloorColor]) {
				movingFloor = new Pushable(lookup[movingFloorColor]);
				movingFloor.type = "floor";
				movingFloor.active = true;
				add(movingFloor);
			}
			
			feedback = new BitmapData(data.width, data.height, true, 0x0);
			feedbackImage = new Image(feedback);
			addGraphic(feedbackImage, -10);
			
			updateLists();
			resetState();
		}
		
		private static function getColorAboveLava (data:BitmapData, i:int, j:int):uint
		{
			var colors:Array = [];
			
			colors.push(data.getPixel32(i-1, j));
			colors.push(data.getPixel32(i+1, j));
			colors.push(data.getPixel32(i, j-1));
			colors.push(data.getPixel32(i, j+1));
			
			var c:uint;
			var lastValid:uint;
			
			for (i = 0; i < 4; i++) {
				c = colors[i];
				
				if (c == lavaColor || c == floorColor || c == fakeLavaColor) {
					continue;
				}
				
				lastValid = c;
				
				for (j = i+1; j < 4; j++) {
					if (colors[j] == c) return c;
				}
			}
			
			return lastValid;
		}
		
		public static function clearFeedback ():void
		{
			feedback.fillRect(feedback.rect, 0x0);
		}
		
		public static function updateFeedback ():void
		{
			feedbackImage.updateBuffer();
			feedbackImage.alpha = 1.0;
		}
		
		private function sortWalls ():void
		{
			walls.reverse();
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
		
		public function refocus (instant:Boolean = false): Boolean
		{
			var e:Pushable;
			
			var rect:Rectangle;
			
			FP.point.x = player.x;
			FP.point.y = player.y;
			FP.point2.x = player.x;
			FP.point2.y = player.y;
			
			for each (e in walls) {
				if (! e.active) continue;
				
				rect = e.bounds;
				
				FP.point.x = Math.min(FP.point.x, rect.x);
				FP.point.y = Math.min(FP.point.y, rect.y);
				
				FP.point2.x = Math.max(FP.point2.x, rect.x+rect.width);
				FP.point2.y = Math.max(FP.point2.y, rect.y+rect.height);
			}
			
			var found:Boolean = false;
			
			for each (e in walls) {
				if (e.active) continue;
				
				rect = e.bounds;
				
				if (rect.x <= FP.point.x && rect.y <= FP.point.y
					&& rect.x+rect.width >= FP.point2.x
					&& rect.y+rect.height >= FP.point2.y)
				{
					found = true;
					break;
				}
			}
			
			if (! found) return false;
			
			visibleBounds = rect;
			
			rect = rect.clone();
			
			rect.x += 1;
			rect.y += 1;
			
			rect.width -= 2;
			rect.height -= 2;
			
			var borderX:int = 16;
			var borderY:int;
			
			var scale:Number = (FP.stage.stageWidth - borderX*2) / rect.width;
			
			if (FP.screen.scale == scale) return false;
			
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
				
				FP.tween(FP.screen, {scale: scale, x: screenX, y: screenY}, tweenTime, {delay: 16});
			}
			
			return true;
		}
		
		public function resetState():void
		{
			var i:int;
			var p:Point;
			
			for (i = 0; i < walls.length; i++) {
				p = saveFile.walls[i];
				
				if (p) {
					var wall:Pushable = walls[i];
					wall.x = p.x;
					wall.y = p.y;
					wall.active = true;
				}
			}
			
			for each (p in saveFile.checkpoints) {
				var checkpoint:Entity = collidePoint("checkpoint", p.x, p.y);
				
				if (checkpoint) {
					remove(checkpoint);
				}
				
				player.x = p.x;
				player.y = p.y;
			}
		}
		
		public function hitCheckpoint (checkpoint:Entity):void
		{
			remove(checkpoint);
			
			saveFile.checkpoints.push(new Point(checkpoint.x, checkpoint.y));
			
			var found:Boolean = false;
			
			for (var i:int = 0; i < walls.length; i++) {
				var e:Pushable = walls[i];
				
				if (e.active) {
					saveFile.walls[i] = new Point(e.x, e.y);
					continue;
				}
				
				if (found) continue;
				
				var rect:Rectangle = e.bounds;
				
				if (rect.x <= checkpoint.x && rect.y <= checkpoint.y
					&& rect.x+rect.width >= checkpoint.x
					&& rect.y+rect.height >= checkpoint.y)
				{
					saveFile.walls[i] = new Point(0,0);
					
					e.active = true;
					
					var changedScale:Boolean = refocus();
					
					function highlightWall ():void
					{
						Image(e.graphic).tintMode = 1.0;
						
						FP.tween(e.graphic, {tintMode: 0.0}, 32);
					}
					
					highlightWall();
					
					found = true;
				}
			}
		}
		
		public override function begin (): void
		{
			refocus(true);
		}
		
		public override function update (): void
		{
			if (Input.pressed(Key.R)) {
				if (Main.debugMode) {
					checkForNewLevel();
				} else {
					resetState();
				}
				return;
			}
			
			if (Input.pressed(Key.ESCAPE)) {
				FP.world = new Menu;
				saveFile = null;
				return;
			}
			
			for each (var wall:Pushable in walls) {
				wall.moving = false;
			}
			if (movingFloor) movingFloor.moving = false;
			super.update();
			
			if (player.x < visibleBounds.x || player.x >= visibleBounds.x + visibleBounds.width
				|| player.y < visibleBounds.y || player.y >= visibleBounds.y + visibleBounds.height) {
				if (Main.debugMode && classCount(Checkpoint) != 0) {
					var a:Array = [];
					collideRectInto("checkpoint", visibleBounds.x, visibleBounds.y, visibleBounds.width, visibleBounds.height, a);
					
					for each (var checkpoint:Checkpoint in a) {
						hitCheckpoint(checkpoint);
					}
					
					return;
				}
				saveFile = null;
				FP.world = new Congrats;
			}
		}
		
		public override function render (): void
		{
			feedbackImage.alpha -= 1/16;
			if (feedbackImage.alpha < 0) feedbackImage.alpha = 0;
			
			super.render();
		}
	}
}

