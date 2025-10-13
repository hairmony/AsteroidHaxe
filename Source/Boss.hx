package;
import flixel.FlxState;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.util.FlxTimer;
import flixel.FlxG;
import flixel.math.FlxPoint;
import flixel.math.FlxAngle;
import flixel.tweens.FlxTween;
import flixel.math.FlxMath;

class Boss extends FlxSprite 
{
	static var BULLET_ASSET:Int = 3; // The bullets the boss fires

	static var BOSS_HP_MAX = 75;
	public var hp:Int = BOSS_HP_MAX; // Amount of hits to kill it

	public var BOSS_CIRCLE_ATTACK_DELAY:Float = 0.5; // Boss attacks every x seconds
	public static var BOSS_CIRCLE_SHOT_AMOUNT:Int = 12;

	public var BOSS_WALL_ATTACK_DELAY:Float = 0.75; // Gap between lines formed
	public static var BOSS_WALL_SHOT_AMOUNT:Int = 28;
	public static var BOSS_WALL_GAP_SIZE = 6;
	public static var BOSS_WALL_GAP_STEP = 3;
	public static var BOSS_WALL_MOVEMENT_SPEED:Float = 150; // How fast the boss moves!

	var patternAngle:Float = 0;
	var attackTimer:FlxTimer; // Timer between attack patterns
	var bossType:Int = 0;

	public function new(X:Float, Y:Float, assetID:Int = 0, bossType:Int = 0)
	{
		super(X, Y);

		if (FlxG.sound.music != null)
		{
			FlxTween.tween(
				FlxG.sound.music, 
				{ volume: 0 }, 
				1.0, 
				{ onComplete: function(_) {
					FlxG.sound.playMusic("assets/music/BossMusic.ogg", 0.5, true);
				}}
			);
		}
		else
			FlxG.sound.playMusic("assets/music/BossMusic.ogg", 0.5, true);


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
			spinAddtion = -6.5;
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

	    velocity.x = gapDirection * BOSS_WALL_MOVEMENT_SPEED;

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

		if (FlxG.sound.music != null)
		{
			FlxTween.tween(
				FlxG.sound.music, 
				{ volume: 0 }, 
				1.0, 
				{ onComplete: function(_) {
					FlxG.sound.playMusic("assets/music/LevelMusic.ogg", 0.5, true);
				}}
			);
		}
		else
			FlxG.sound.playMusic("assets/music/LevelMusic.ogg", 0.5, true);


		super.kill();
	}

	// I have to do this for some reason 
	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);

		if (velocity.x != 0)
        {
            var oldX = x;
            x = FlxMath.bound(x, 0, FlxG.width - width);
            
            // If boss hits boundary STOP
            if (x != oldX)
            {
                velocity.x = 0;
            }
        }
	}
}