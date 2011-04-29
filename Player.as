package
{
	import org.flixel.*;

	public class Player extends FlxSprite
	{
		[Embed(source="spaceman.png")] private var ImgSpaceman:Class;
		
		private var _jumpPower:int;
		private var _up:Boolean;
		private var _down:Boolean;
		private var _restart:Number;

		
		public function Player(X:int,Y:int)
		{
			super(X,Y);
			loadGraphic(ImgSpaceman,true,true,16);
			_restart = 0;
			
			//bounding box tweaks
			width = 14;
			height = 14;
			offset.x = 1;
			offset.y = 1;
			
			//basic player physics
			var runSpeed:uint = 80;
			drag.x = runSpeed*8;
			acceleration.y = 420;
			_jumpPower = 200;
			maxVelocity.x = runSpeed;
			maxVelocity.y = _jumpPower;
			
			//animations
			addAnimation("idle", [0]);
			addAnimation("run", [1, 2, 3, 0], 12);
			addAnimation("jump", [4]);
			addAnimation("idle_up", [5]);
			addAnimation("run_up", [6, 7, 8, 5], 12);
			addAnimation("jump_up", [9]);
			addAnimation("jump_down", [10]);
		}
		
		override public function update():void
		{
			//MOVEMENT
			acceleration.x = 0;
			if(FlxG.keys.LEFT)
			{
				facing = LEFT;
				acceleration.x -= drag.x;
			}
			else if(FlxG.keys.RIGHT)
			{
				facing = RIGHT;
				acceleration.x += drag.x;
			}
			if(FlxG.keys.justPressed("UP") && !velocity.y)
			{
				velocity.y = -_jumpPower;
			}
			
			//AIMING
			_up = false;
			_down = false;
			if(FlxG.keys.UP) _up = true;
			else if(FlxG.keys.DOWN && velocity.y) _down = true;
			
			//ANIMATION
			if(velocity.y != 0)
			{
				if(_up) play("jump_up");
				else if(_down) play("jump_down");
				else play("jump");
			}
			else if(velocity.x == 0)
			{
				if(_up) play("idle_up");
				else play("idle");
			}
			else
			{
				if(_up) play("run_up");
				else play("run");
			}
				
			super.update();
		}
		
		override public function kill():void
		{
			solid = false;
			super.kill();
			flicker(-1);
			exists = true;
			visible = false;
		}
	}
}