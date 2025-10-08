package;

import flixel.FlxState;
import flixel.FlxObject;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.util.FlxSpriteUtil;
import flixel.text.FlxText;

class PlayState extends FlxState
{
	var ship:Player;
	var asteroid:Asteroid;//Make this a FlxGroup to spawn in multiple
	var projectiles:FlxGroup;
	var scoreText:FlxText;
	var multishotText:FlxText; // New text to track multishot

	// Score tracking variables
	public var asteroidHits:Float = 0;
	public var enemyHits:Float = 0;
	public var accuracyBonus:Float = 0;
	public var score:Float = 0;

	// Variables for the multi-shot cooldown
	public var multishotCharge:Float = 0;
	public static var MULTISHOT_CHARGE_MAX:Float = 1; // in number of objects killed
	// TO BE CHANGED FROM 1

	override public function create():Void
	{
		FlxG.sound.playMusic("assets/music/Levelmusic.ogg", 1, true);
		super.create();

		//Create text
		scoreText = new FlxText(25,25,0, "Score: " + score, 16); //add 5th argument as true if we are adding custom fonts
		add(scoreText);

		multishotText = new FlxText(25,45,0, "Super: " + multishotCharge + "/" + MULTISHOT_CHARGE_MAX, 16);
		add(multishotText);
		
		// Spawn in player
		ship = new Player();
		add(ship);

		// Moved player spawn to bottom of the screen
		ship.x = FlxG.width / 2;
		ship.y = FlxG.height - 50;

		// Spawn in stationary test asteroid
		asteroid = new Asteroid();
		add(asteroid);

		// New projectile group
		projectiles = new FlxGroup(); 
		add(projectiles);
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);

		//Prevents the player from going offscreen
		FlxSpriteUtil.cameraBound(ship);

		if (FlxG.keys.justPressed.R)
		{
			FlxG.resetState(); // Reset with R key
		}

		// Default: shoot 1 projectile with LMB
		if (FlxG.mouse.justPressed)
		{
			var p = new Projectile(ship.getGraphicMidpoint().x, ship.getGraphicMidpoint().y, ship.angle - 90, 0);
			projectiles.add(p); // Add projectile to group
		}

		// Multishot: shoot 8 projectiles in a circle
		if (FlxG.keys.justPressed.SPACE && multishotCharge >= MULTISHOT_CHARGE_MAX)
		{
			// Reset the cooldown
			multishotCharge = 0;

			var angleIncrement = 0;
			for (i in 0...8)
			{
				// We use ship.angle here to base the shot direction on where the ship is facing
				var p = new Projectile(ship.getGraphicMidpoint().x, ship.getGraphicMidpoint().y, ship.angle + angleIncrement, 1);
				projectiles.add(p); // Add projectile to group
				angleIncrement += 45;
			}
		}

		FlxG.overlap(asteroid, ship, collide);
		FlxG.overlap(asteroid, projectiles, collideProjectile); // Check for collisions between asteroids, projectiles
		// FlxG.overlap(enemy, projectiles, collideProjectile); // For when enemy is added
	}

	function collide(object1:FlxObject, object2:FlxObject):Void
	{
		object2.setPosition(50,50);
	}

	// Function handles projectile collision
	function collideProjectile(object1:FlxObject, object2:FlxObject):Void
	{
		// Check if the object is an Asteroid
		if (Std.isOfType(object1, Asteroid))
		{
			// Add to asteroid kill count
			asteroidHits++;
		}
		// Add in when we have Enemy objects
		// else if (Std.isOfType(object1, Enemy))
		// {
		// 	// Add to the enemy kill count
		// 	enemyHits++;
		// }

		// Add to multishot charge when object is hit
		if (multishotCharge < MULTISHOT_CHARGE_MAX)
		{
			multishotCharge++;
			updateMultishotText(); // Update the display
		}

		// Kill both the asteroid and the projectile
		object1.kill();
		object2.kill();

		// Update score
		updateScoreText();
	}

	function updateMultishotText():Void
	{
		multishotText.text = "Super: " + multishotCharge + " / " + MULTISHOT_CHARGE_MAX;
	}

	// Function calculates score for player
	function updateScoreText():Float
	{
		// Currently DOES NOT track multiplier bonuses
		// Add code here for multiplier
		score = asteroidHits * 100 + enemyHits * 200; // Calculating the base score
		scoreText.text = "Score: " + score;

		return(score);
	}
}

