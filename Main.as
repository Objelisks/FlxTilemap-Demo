package
{
	import org.flixel.*;
	
	[SWF(width="400", height="300", backgroundColor="#000000")]
	
	/**
	 * ...
	 * @author Lord Tim
	 */
	public class Main extends FlxGame
	{
		
		public function Main():void
		{
			super(400, 300, MenuState, 1);
		}
	}
}