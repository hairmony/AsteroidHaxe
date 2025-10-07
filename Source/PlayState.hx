package;

import flixel.FlxState;
import flixel.FlxObject;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;

class PlayState extends FlxState
{
	var ship:Player;
	var asteroid:Asteroid;
	var projectiles:FlxGroup;

	override public function create():Void
	{
		super.create();

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

		if (FlxG.keys.justPressed.R)
		{
			FlxG.resetState(); // Reset with R key
		}

		// Check for LMB
		if (FlxG.mouse.justPressed)
		{
			var p = new Projectile(ship.getGraphicMidpoint().x, ship.getGraphicMidpoint().y, ship.angle - 90);
			projectiles.add(p); // Add projectile to group
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
	}
}

