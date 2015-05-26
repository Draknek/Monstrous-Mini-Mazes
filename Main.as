package
{
	import net.flashpunk.*;
	import net.flashpunk.debug.*;
	import net.flashpunk.graphics.*;
	import net.flashpunk.utils.*;
	
	import flash.system.*;
	
	public class Main extends Engine
	{
		[Embed(source = 'fonts/7x5.ttf', embedAsCFF="false", fontFamily = '7x5')]
		public static const FONT:Class;
		[Embed(source = 'fonts/amiga4ever pro2.ttf', embedAsCFF="false", fontFamily = 'amiga')]
		public static const FONT2:Class;
		
		public static const TW:int = 5;
		public static const wallHeight:int = 2;
		
		public static var debugMode:Boolean = false;
		
		public static var touchscreen:Boolean = false;
		public static var isAndroid:Boolean = false;
		public static var isIOS:Boolean = false;
		public static var isPlaybook:Boolean = false;
		
		public function Main () 
		{
			if (Capabilities.manufacturer.toLowerCase().indexOf("ios") != -1) {
				isIOS = true;
				touchscreen = true;
			}
			else if (Capabilities.manufacturer.toLowerCase().indexOf("android") >= 0) {
				isAndroid = true;
				touchscreen = true;
			} else if (Capabilities.os.indexOf("QNX") >= 0) {
				isPlaybook = true;
				touchscreen = true;
			}
			super(80*TW, 60*TW, 60, true);
			
			FP.screen.color = 0xdeeed6;
			FP.screen.scale = 8;
			Text.font = "amiga";
			Text.size = 8;
			
			Audio.init(this);
			
			//FP.console.enable();
		}
		
		public override function init (): void
		{
			sitelock("draknek.org");
			
			super.init();
			
			FP.world = debugMode ? new Level() : new Menu();
			
			stage.quality = "low";
		}
		
		public override function update (): void
		{
			if (Input.pressed(FP.console.toggleKey)) {
				// Doesn't matter if it's called when already enabled
				FP.console.enable();
			}
			
			super.update();
		}
		
		public function sitelock (allowed:*):Boolean
		{
			var url:String = FP.stage.loaderInfo.url;
			var startCheck:int = url.indexOf('://' ) + 3;
			
			if (url.substr(0, startCheck) == 'file://') {
				debugMode = true;
				return true;
			}
			
			if (url.substr(0, startCheck) != 'http://'
				&& url.substr(0, startCheck) != 'https://'
				&& url.substr(0, startCheck) != 'ftp://') return true;
			
			var domainLen:int = url.indexOf('/', startCheck) - startCheck;
			var host:String = url.substr(startCheck, domainLen);
			
			if (allowed is String) allowed = [allowed];
			for each (var d:String in allowed)
			{
				if (host.substr(-d.length, d.length) == d) return true;
			}
			
			parent.removeChild(this);
			throw new Error("Error: this game is sitelocked");
			
			return false;
		}
	}
}

