package
{
	import net.flashpunk.*;
	import net.flashpunk.graphics.*;
	import net.flashpunk.masks.*;
	import net.flashpunk.utils.*;
	
	public class Congrats extends World
	{
		public function Congrats ()
		{
			var text:Text = new Text("Congrats!\nYou escaped\nfrom the\nmonstrous\nmini mazes", 0, 0, {color: 0x30346d, align: "center"});
			
			text.x = (FP.width - text.width + 1)*0.5;
			text.y = (FP.height - text.height + 1)*0.5;
			
			addGraphic(text);
		}
		
		public override function begin (): void
		{
			Input.mouseCursor = "auto";
			
			FP.screen.scale = 8;
			FP.screen.x = 0;
			FP.screen.y = 0;
		}
		
		public override function update ():void
		{
			if (Input.pressed(Key.ESCAPE)) {
				FP.world = new Menu;
				return;
			}
			
			super.update();
		}
		
		public override function render (): void
		{
			super.render();
		}
	}
}

