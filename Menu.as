package
{
	import net.flashpunk.*;
	import net.flashpunk.graphics.*;
	import net.flashpunk.masks.*;
	import net.flashpunk.utils.*;
	
	public class Menu extends World
	{
		//[Embed(source="images/bg.png")] public static const BgGfx: Class;
		
		public function Menu ()
		{
			var title:Text = new Text("Monstrous\nMini Mazes", 0, 0, {color: 0x30346d, align: "center"});
			
			title.x = (FP.width - title.width + 1)*0.5;
			
			addGraphic(title);
			
			var start:Button = new Button("Start", 0, gotoLevel);
			
			start.y = title.height + (FP.height - title.height - start.height)*0.5;
			
			add(start);
		}
		
		public static function gotoLevel ():void
		{
			FP.world = new Level;
		}
		
		public override function begin (): void
		{
			
		}
		
		public override function end (): void
		{
			Input.mouseCursor = "auto";
		}
		
		public override function update ():void
		{
			Input.mouseCursor = "auto";
			
			super.update();
		}
		public override function render (): void
		{
			super.render();
		}
	}
}

