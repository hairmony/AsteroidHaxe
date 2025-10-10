package;
import flixel.FlxState;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.group.FlxGroup;
import flixel.util.FlxSpriteUtil;

class Enemy extends FlxSprite 
{
	public static var ENEMY_SPEED:Int = 55; //Default value
	var initX:Float;//used to track the inital x coordinate of the enemy
	var spawnSide:Int; // Tracks if it spawned on left = 0 or right = 1

	public function new(Angle:Float = 0, assetID:Int = 0)
	{
		super();

		var asset = switch(assetID){
			case 0: "assets/images/Enemy.png";
			case 1: "assets/images/Enemy2.png";
			default: "assets/images/Enemy.png";
		}

		loadGraphic(asset, false);

		spawnSide = FlxG.random.int(0,1);

		// initX = FlxG.random.int(0,1) * (FlxG.width - 32);
		// x = initX;

		if (spawnSide == 0) {
            x = -32; // off-screen left
            velocity.x = ENEMY_SPEED; // move right
        } else {
            x = FlxG.width; // off-screen right
            velocity.x = -ENEMY_SPEED; // move left
        }

        initX = x; // Saves initial position
        y = FlxG.random.float(0.0,1.0) * (FlxG.height - 32);

        this.angle = Angle + 180;

		// scale.set(0.1,0.1);
		updateHitbox();

		// //Make enemies travel left or right depending on initial x spawn
		// if (x == 0){
		// 	velocity.x = ENEMY_SPEED;
		// } else {
		// 	velocity.x = -ENEMY_SPEED;
		// }
	}

	override public function update(elapsed:Float):Void {
		super.update(elapsed);

		// if (!isOnScreen()) {
		// 	y = FlxG.random.float(0.0,1.0) * (FlxG.height - 32);
		// 	x = initX; //reset back to initial x
		// }

		// When enemy goes off the opposite side it spawn, bring back to spawn
        if (x + width < 0 || x > FlxG.width) {
            // respawn on same side it originally came from
            y = FlxG.random.float(0.0,1.0) * (FlxG.height - 32);

            if (spawnSide == 0) {
                x = FlxG.width;
                velocity.x = -ENEMY_SPEED;
            } else {
                x = -32; 
                velocity.x = ENEMY_SPEED;
            }
        }		
	}
}