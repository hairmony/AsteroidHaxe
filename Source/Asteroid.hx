package;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.util.FlxSpriteUtil;

class Asteroid extends FlxSprite {
	public static var ASTEROID_SPEED:Int = 100; //Default value
	public var isDead:Bool = false;

	
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

		// loadGraphic(asset, true, 96, 96);
		// centerOrigin();
		// width = 32;
		// height = 32;
		// offset.set(29,32);

		loadGraphic(asset, true, 32, 32);
		animation.add("death", [1,2,3,4,5,6,7,8,9,10], 24, false);
		
		// x = FlxG.random.float(0.0,1.0) * (FlxG.width - 32);
		// y = 0; //Always spawn at the top

		resetPosition();
	}

	function resetPosition():Void
	{
		x = FlxG.random.float(0, FlxG.width - width);
		y = -height; // Start just above the screen

		velocity.x = FlxG.random.float(-50, 50); // Slight horizontal drift
		velocity.y = ASTEROID_SPEED;
	}

	override public function update(elapsed:Float):Void {
		super.update(elapsed);

		velocity.y = ASTEROID_SPEED;
		velocity.x = FlxG.random.float(-50.0,50.0);

		if (y > FlxG.height) 
		{
			resetPosition();
		}
	}
}