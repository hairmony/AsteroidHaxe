package;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.util.FlxSpriteUtil;

class Asteroid extends FlxSprite {
	public static var ASTEROID_SPEED:Int = 100; //Default value
	public function new(){
		super();
		loadGraphic("assets/images/Asteroid.png");

		x = FlxG.random.float(0.0,1.0) * FlxG.width;
		y = 0; //Always spawn at the top

	}

	override public function update(elapsed:Float):Void {
		super.update(elapsed);

		velocity.y = ASTEROID_SPEED;
		velocity.x = FlxG.random.float(-50.0,50.0);

		if (!isOnScreen()){
			y = 0;
			x = FlxG.random.float(0.0,1.0) * FlxG.width;
			velocity.x = FlxG.random.float(-50.0,50.0);
		}
	}
}