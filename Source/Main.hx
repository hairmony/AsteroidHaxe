package;

import openfl.display.Sprite;
import flixel.FlxGame;

class Main extends Sprite
{
	public function new()
	{
		super();
		addChild(new FlxGame(480, 360, MenuState));
	}
}