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
	public static var SCORE = 0;

	// Variables for the multi-shot cooldown
	var multishotCooldown:Float = 0;
	static inline var MULTISHOT_DELAY:Float = 10; // in seconds

	override public function create():Void
	{
		FlxG.sound.playMusic("assets/music/Levelmusic.ogg", 1, true);
		super.create();

		//Create text
		scoreText = new FlxText(25,25,0, "Score: " + SCORE, 16); //add 5th argument as true if we are adding custom fonts
		add(scoreText);
		
		// Spawn in player
		ship = new Player();
		add(ship);

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

		// Multishot cooldown decrement
		if (multishotCooldown > 0)
		{

			// This code can be changed so
			// cooldown is based on enemies hit
			// instead of time
			multishotCooldown -= elapsed;
		}

		// Multishot: shoot 8 projectiles in a circle
		if (FlxG.keys.justPressed.SPACE && multishotCooldown <= 0)
		{
			// Reset the cooldown
			multishotCooldown = MULTISHOT_DELAY;

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
		// Kill both the asteroid and the projectile
		object1.kill();
		object2.kill();

		// Add 10 points for the destruction of the asteroid
		// WILL ADD SCORE FUNCTION TO ACCOUNT FOR MULTIPLIER AND ENEMY TYPE
		// Will be implemented once enemies are implemented
		SCORE += 10;
		scoreText.text = "Score: " + SCORE;
	}
}

