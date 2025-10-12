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

	static var BOSS_HP_MAX = 75;
	public var hp:Int = BOSS_HP_MAX; // Amount of hits to kill it

	public var BOSS_CIRCLE_ATTACK_DELAY:Float = 1.5; // Boss attacks every x seconds
	public static var BOSS_CIRCLE_SHOT_AMOUNT:Int = 14;

	public var BOSS_WALL_ATTACK_DELAY:Float = 2.0; // Gap between lines formed
	public static var BOSS_WALL_SHOT_AMOUNT:Int = 16;
	public static var BOSS_WALL_GAP_SIZE = 2;
	public static var BOSS_WALL_GAP_STEP = 3;

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
		if (!alive || PauseState.isPaused) // This is how you pause the game!
		{
			return;
		}

		var angleIncrement:Float = 360 / BOSS_CIRCLE_SHOT_AMOUNT;

		var spinAddtion:Float = 0;
		var shootDelayMultiplier:Float = 1;

		if (hp <= BOSS_HP_MAX / 2)
		{
			spinAddtion = 6;
			shootDelayMultiplier = 0.8; // lower number is faster (its the percentage of DELAY)
		}

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

		patternAngle += 2 + spinAddtion;
		attackTimer.start(BOSS_CIRCLE_ATTACK_DELAY * shootDelayMultiplier, firePatternCircle, 0);
	}

	var lastGapPosition:Int = FlxG.random.int(0, BOSS_WALL_SHOT_AMOUNT - BOSS_WALL_GAP_SIZE);
	var gapDirection:Int = 1;

	private function firePatternWall(timer:FlxTimer):Void
	{
		if (!alive || PauseState.isPaused) 
			return;

	    var playState:PlayState = cast(FlxG.state, PlayState);
	    if (playState == null) 
	    	return;

	    // var gapPosition = FlxG.random.int(0, BOSS_WALL_SHOT_AMOUNT - BOSS_WALL_GAP_SIZE); // Randomly choose a gap
	    var bulletSpacing = FlxG.width / BOSS_WALL_SHOT_AMOUNT;

	    var gapPosition = lastGapPosition + (gapDirection * BOSS_WALL_GAP_STEP);

	    if (gapPosition < 0)
	    { 
	    	gapPosition = 0;
	    	gapDirection = 1;
	    }
		else if (gapPosition > BOSS_WALL_SHOT_AMOUNT - BOSS_WALL_GAP_SIZE)
		{
    		gapPosition = BOSS_WALL_SHOT_AMOUNT - BOSS_WALL_GAP_SIZE;
    		gapDirection = -1;
    	}

	    lastGapPosition = gapPosition;

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