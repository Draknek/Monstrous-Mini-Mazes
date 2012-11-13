package
{
	import net.flashpunk.*;
	import net.flashpunk.graphics.*;
	import net.flashpunk.masks.*;
	import net.flashpunk.utils.*;
	
	import flash.display.*;
	
	public class Lava extends Entity
	{
		public static var color2:uint = 0xFF442434;
		
		public function Lava (data:BitmapData)
		{
			var c:uint = 0xFF000000 | Level.lavaColor;
			
			visible = false;
			type = "lava";
			
			var bitmap:BitmapData = new BitmapData(data.width*Main.TW, data.height*Main.TW, true, 0x0);
			
			for (var i:int = 0; i < data.width; i++) {
				for (var j:int = 0; j < data.height; j++) {
					if (! data.getPixel32(i, j)) continue;
					
					FP.rect.width = Main.TW+2;
					FP.rect.height = Main.TW;
					FP.rect.x = i*Main.TW-1;
					FP.rect.y = j*Main.TW;
					
					bitmap.fillRect(FP.rect, c);
					
					FP.rect.width = Main.TW;
					FP.rect.height = Main.TW+2;
					FP.rect.x = i*Main.TW;
					FP.rect.y = j*Main.TW-1;
					
					bitmap.fillRect(FP.rect, c);
				}
			}
			
			for (i = 0; i < bitmap.width; i++) {
				for (j = 0; j < bitmap.height; j++) {
					if (bitmap.getPixel32(i, j) && ! bitmap.getPixel32(i, j-1)) {
						bitmap.setPixel32(i, j, color2);
					}
				}
			}
			
			graphic = new Stamp(bitmap);
			
			graphic.y = 3;
			
			mask = new Pixelmask(data);
		}
	}
}

