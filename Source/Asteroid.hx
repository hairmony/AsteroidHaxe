package;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.util.FlxSpriteUtil;

class Asteroid extends FlxSprite {
	public static var ASTEROID_SPEED:Int = 100; //Default value
	
	public function new(assetID:Int = 0)
	{
		super();

		var asset = switch(assetID) {
            case 0: "assets/images/Asteroid.png";
            case 1: "assets/images/Asteroid2.png";
            case 2: "assets/images/Asteroid3.png";
            case 3: "assets/images/Asteroid4.png";
            default: "assets/images/Asteroid.png";
        };

		loadGraphic(asset, false);

		x = FlxG.random.float(0.0,1.0) * (FlxG.width - 32);
		y = 0; //Always spawn at the top

	}

	override public function update(elapsed:Float):Void {
		super.update(elapsed);

		velocity.y = ASTEROID_SPEED;
		velocity.x = FlxG.random.float(-50.0,50.0);

		if (!isOnScreen()) {
			y = 0;
			x = FlxG.random.float(0.0,1.0) * (FlxG.width - 32);
		}
	}
}