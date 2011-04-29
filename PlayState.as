package
{
	import flash.display.BlendMode;
	import org.flixel.*;

	public class PlayState extends FlxState
	{
		// Tileset that works with AUTO mode (best for thin walls)
		[Embed(source = 'auto_tiles.png')]private static var auto_tiles:Class;
		
		// Tileset that works with ALT mode (best for thicker walls)
		[Embed(source = 'alt_tiles.png')]private static var alt_tiles:Class;
		
		// Tileset that works with OFF mode (do what you want mode)
		[Embed(source = 'empty_tiles.png')]private static var empty_tiles:Class;
		
		// Default tilemaps. Embedding text files is a little weird.
		[Embed(source = 'default_auto.txt', mimeType = 'application/octet-stream')]private static var default_auto:Class;
		[Embed(source = 'default_alt.txt', mimeType = 'application/octet-stream')]private static var default_alt:Class;
		[Embed(source = 'default_empty.txt', mimeType = 'application/octet-stream')]private static var default_empty:Class;
		
		// Some static constants for the size of the tilemap tiles
		private const TILE_WIDTH:uint = 16;
		private const TILE_HEIGHT:uint = 16;
		
		// The FlxTilemap we're using
		private var collisionMap:FlxTilemap;
		
		// Box to show the user where they're placing stuff
		private var highlightBox:FlxObject;
		
		// Player class modifed from "Mode" demo
		private var player:Player;
		
		// Some interface buttons and text
		private var autoAltBtn:FlxButton;
		private var resetBtn:FlxButton;
		private var quitBtn:FlxButton;
		private var helperTxt:FlxText;
		
		override public function create():void
		{
			FlxG.framerate = 50;
			FlxG.flashFramerate = 50;
			
			// Creates a new tilemap with no arguments
			collisionMap = new FlxTilemap();
			
			/*
			 * FlxTilemaps are created using strings of comma seperated values (csv)
			 * This string ends up looking something like this:
			 *
			 * 0,0,0,0,0,0,0,0,0,0,
			 * 0,0,0,0,0,0,0,0,0,0,
			 * 0,0,0,0,0,0,1,1,1,0,
			 * 0,0,1,1,1,0,0,0,0,0,
			 * ...
			 *
			 * Each '0' stands for an empty tile, and each '1' stands for
			 * a solid tile
			 *
			 * When using the auto map generation, the '1's are converted into the corresponding frame
			 * in the tileset.
			 */
			
			// Initializes the map using the generated string, the tile images, and the tile size
			collisionMap.loadMap(new default_auto(), auto_tiles, TILE_WIDTH, TILE_HEIGHT, FlxTilemap.AUTO);
			add(collisionMap);
			
			highlightBox = new FlxObject(0, 0, TILE_WIDTH, TILE_HEIGHT);
			
			player = new Player(64, 220);
			add(player);
			
			// When switching between modes here, the map is reloaded with it's own data, so the positions of tiles are kept the same
			// Notice that different tilesets are used when the auto mode is switched
			autoAltBtn = new FlxButton(4, FlxG.height - 24, "AUTO", function():void
			{
				switch(collisionMap.auto)
				{
					case FlxTilemap.AUTO:
						collisionMap.loadMap(FlxTilemap.arrayToCSV(collisionMap.getData(true), collisionMap.widthInTiles),
							alt_tiles, TILE_WIDTH, TILE_HEIGHT, FlxTilemap.ALT);
						autoAltBtn.label.text = "ALT";
						break;
					case FlxTilemap.ALT:
						collisionMap.loadMap(FlxTilemap.arrayToCSV(collisionMap.getData(true), collisionMap.widthInTiles),
							empty_tiles, TILE_WIDTH, TILE_HEIGHT, FlxTilemap.OFF);
						autoAltBtn.label.text = "OFF";
						break;
					case FlxTilemap.OFF:
						collisionMap.loadMap(FlxTilemap.arrayToCSV(collisionMap.getData(true), collisionMap.widthInTiles),
							auto_tiles, TILE_WIDTH, TILE_HEIGHT, FlxTilemap.AUTO);
						autoAltBtn.label.text = "AUTO";
						break;
				}
				
			});
			add(autoAltBtn);
			
			resetBtn = new FlxButton(8 + autoAltBtn.width, FlxG.height - 24, "Reset", function():void
			{
				switch(collisionMap.auto)
				{
					case FlxTilemap.AUTO:
						collisionMap.loadMap(new default_auto(), auto_tiles, TILE_WIDTH, TILE_HEIGHT, FlxTilemap.AUTO);
						player.x = 64;
						player.y = 220;
						break;
					case FlxTilemap.ALT:
						collisionMap.loadMap(new default_alt(), alt_tiles, TILE_WIDTH, TILE_HEIGHT, FlxTilemap.ALT);
						player.x = 64;
						player.y = 128;
						break;
					case FlxTilemap.OFF:
						collisionMap.loadMap(new default_empty(), empty_tiles, TILE_WIDTH, TILE_HEIGHT, FlxTilemap.OFF);
						player.x = 64;
						player.y = 64;
						break;
				}
			});
			add(resetBtn);
			
			quitBtn = new FlxButton(FlxG.width - resetBtn.width - 4, FlxG.height - 24, "Quit",
				function():void { FlxG.fade(0xff000000, 0.22, function():void { FlxG.switchState(new MenuState()); } ); } );
			add(quitBtn);
			
			helperTxt = new FlxText(12 + autoAltBtn.width*2, FlxG.height - 30, 150, "Click to place tiles\nShift-Click to remove tiles\nArrow keys to move");
			add(helperTxt);
		}
		
		override public function update():void
		{
			wrap(player);
			
			// Tilemaps can be collided just like any other FlxObject, and flixel
			// automatically collides each individual tile with the object
			FlxG.collide(player, collisionMap);
			
			highlightBox.x = Math.floor(FlxG.mouse.x / TILE_WIDTH) * TILE_WIDTH;
			highlightBox.y = Math.floor(FlxG.mouse.y / TILE_HEIGHT) * TILE_HEIGHT;
			
			if (FlxG.mouse.pressed())
			{
				// FlxTilemaps can be manually edited at runtime as well
				// Setting a tile to 0 removes it, and setting it to anything else will place a tile
				// If auto map is on, the map will automatically update all surrounding tiles
				collisionMap.setTile(FlxG.mouse.x / TILE_WIDTH, FlxG.mouse.y / TILE_HEIGHT, FlxG.keys.SHIFT?0:1);
			}
			
			super.update();
		}
		
		public override function draw():void
		{
			super.draw();
			highlightBox.drawDebug();
		}
		
		private function wrap(obj:FlxObject):void
		{
			obj.x = (obj.x + obj.width / 2 + FlxG.width) % FlxG.width - obj.width / 2;
			obj.y = (obj.y + obj.height / 2) % FlxG.height - obj.height / 2;
		}
	}
}
