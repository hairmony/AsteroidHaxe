package;
import flixel.FlxState;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.util.FlxTimer;
import flixel.FlxG;
import flixel.math.FlxPoint;
import flixel.math.FlxAngle;

class Boss extends FlxSprite 
{
	static var BULLET_ASSET:Int = 3; // The bullets the boss fires

	public var hp:Int = 75; // Amount of hits to kill it

	public var BOSS_CIRCLE_ATTACK_DELAY:Float = 1.5; // Boss attacks every x seconds
	public static var BOSS_CIRCLE_SHOT_AMOUNT:Int = 14;

	public var BOSS_WALL_ATTACK_DELAY:Float = 2.0; // Gap between lines formed
	public static var BOSS_WALL_SHOT_AMOUNT:Int = 16;
	public static var BOSS_WALL_GAP_SIZE = 2;

	var patternAngle:Float = 0;
	var attackTimer:FlxTimer; // Timer between attack patterns
	var bossType:Int = 0;

	public function new(X:Float, Y:Float, assetID:Int = 0, bossType:Int = 0)
	{
		super(X, Y);

		var asset = switch(assetID){
			case 0: "assets/images/Boss.png";
			case 1: "assets/images/Boss2.png";
			default: "assets/images/Boss.png";
		}

		loadGraphic(asset, false);

		updateHitbox();

		// Boss attack pattern
		if (bossType == 0)
			attackTimer = new FlxTimer().start(BOSS_CIRCLE_ATTACK_DELAY, firePatternCircle, 0);
		else if (bossType == 1)
			attackTimer = new FlxTimer().start(BOSS_WALL_ATTACK_DELAY, firePatternWall, 0);
	}

	private function firePatternCircle(timer:FlxTimer):Void
	{
		if (!alive) // This is how you pause the game!
		{
			return;
		}

		var angleIncrement:Float = 360 / BOSS_CIRCLE_SHOT_AMOUNT;

		for (i in 0...BOSS_CIRCLE_SHOT_AMOUNT)
		{
			var playState:PlayState = cast(FlxG.state, PlayState);
			if (playState != null)
			{
				var angle = patternAngle + (i * angleIncrement);
				var p = new Projectile(getGraphicMidpoint().x, getGraphicMidpoint().y, angle, 2, BULLET_ASSET);

				playState.enemyProjectiles.add(p);
			}
		}

		patternAngle += 10;
	}

	private function firePatternWall(timer:FlxTimer):Void
	{
		if (!alive) 
			return;

	    var playState:PlayState = cast(FlxG.state, PlayState);
	    if (playState == null) 
	    	return;

	    var gapPosition = FlxG.random.int(0, BOSS_WALL_SHOT_AMOUNT - BOSS_WALL_GAP_SIZE); // Randomly choose a gap
	    var bulletSpacing = FlxG.width / BOSS_WALL_SHOT_AMOUNT;

	    for (i in 0...BOSS_WALL_SHOT_AMOUNT)
	    {
	        // Picked gap
	        if (i >= gapPosition && i < gapPosition + BOSS_WALL_GAP_SIZE)
	        {
	            continue;
	        }

	        var bulletX = i * bulletSpacing;
	        // Fire straight down (angle is 0 in a system where 0 is up)
	        var p = new Projectile(bulletX, 0, 90, 2, BULLET_ASSET);

	        playState.enemyProjectiles.add(p);
	    }
	}

	// Override kill() to stop attack timer if boss died
	override public function kill():Void
	{
		if (attackTimer != null)
		{
			attackTimer.cancel();
		}
		super.kill();
	}

	// I have to do this for some reason 
	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
	}
}