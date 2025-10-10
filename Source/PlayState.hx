package;

import flixel.FlxState;
import flixel.FlxObject;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.util.FlxSpriteUtil;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxSave;

class PlayState extends FlxState
{
	var ship:Player;
	var asteroid:FlxGroup;//Make this a FlxGroup to spawn in multiple
	var projectiles:FlxGroup;
	var scoreText:FlxText;
	var multishotText:FlxText; // New text to track multishot
	var gameOverText:FlxText;

	// Score tracking variables
	public var asteroidHits:Float = 0;
	public var enemyHits:Float = 0;
	public var accuracyBonus:Float = 0;
	public var score:Float = 0;

	// Variables for the multi-shot cooldown
	public var multishotCharge:Float = 0;
	public static var MULTISHOT_CHARGE_MAX:Float = 20; // in number of objects killed
	public static var MULTISHOT_SHOT_AMOUNT:Int = 6;
	public static var ASTEROID_AMOUNT:Int = 5;
	
	// Pause menu variables
	var isPaused:Bool = false;
    var pauseGroup:FlxGroup;
    var pauseText:FlxText;

	override public function create():Void
	{
		FlxG.sound.playMusic("assets/music/LevelMusic.ogg", 1, true);
		super.create();

		//Create text
		scoreText = new FlxText(25,25,0, "Score: " + score, 16); //add 5th argument as true if we are adding custom fonts
		add(scoreText);

		multishotText = new FlxText(25,45,0, "Super: " + multishotCharge + "/" + MULTISHOT_CHARGE_MAX, 16);
		add(multishotText);

		gameOverText = new FlxText(0, FlxG.height / 2, FlxG.width, "Transmission Lost", 32);
        gameOverText.alignment = CENTER;
        gameOverText.visible = false;
        add(gameOverText);

        // Ship select from save file
        var save = new FlxSave();
		save.bind("LeftAligned");
		var shipAsset = save.data.shipChoice;
		save.close();
		
		// Spawn in player
		ship = new Player(shipAsset);
		add(ship);

		// Moved player spawn to bottom of the screen
		ship.x = FlxG.width / 2;
		ship.y = FlxG.height - 50;

		// Spawn in stationary test asteroid
		asteroid = new FlxGroup();
		add(asteroid);

		for(i in 0...ASTEROID_AMOUNT) {
			var a = new Asteroid();
			asteroid.add(a);
		}

		// New projectile group
		projectiles = new FlxGroup(); 
		add(projectiles);

		// PAUSE MENU CODE

		// Create pause menu group but keep it hidden initially
        pauseGroup = new FlxGroup();
        pauseGroup.visible = false;
        add(pauseGroup);

        // Dim background
        var bg = new FlxSprite();
        bg.makeGraphic(FlxG.width, FlxG.height, 0x88000000);
        pauseGroup.add(bg);

        // “PAUSED” text
        var pauseText = new FlxText(0, 100, FlxG.width, "PAUSED");
        pauseText.setFormat(null, 32, 0xFFFFFFFF, "center");
        pauseGroup.add(pauseText);

        // Continue button
        var btnContinue = new FlxButton(0, 200, "Continue", onContinue);
        btnContinue.screenCenter(X);
        pauseGroup.add(btnContinue);

        // Restart button
        var btnRestart = new FlxButton(0, 260, "Restart", onRestart);
        btnRestart.screenCenter(X);
        pauseGroup.add(btnRestart);

        // Exit button
        var btnExit = new FlxButton(0, 320, "Exit", onExit);
        btnExit.screenCenter(X);
        pauseGroup.add(btnExit);
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);

		//Prevents the player from going offscreen
		FlxSpriteUtil.cameraBound(ship);

		// Reset button
		if (FlxG.keys.justPressed.R)
		{
			FlxG.resetState(); // Reset with R key
		}

		if (FlxG.keys.justPressed.ESCAPE)
        {
            togglePause();
        }

        // Only run gameplay updates if NOT paused
        if (!isPaused)
        {
            // your normal gameplay code goes here (player movement, collisions, etc.)

            if (ship.alive) // Ship controls disabled if ship is dead
			{
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

					var angleIncrement:Float = 0;
					for (i in 0...MULTISHOT_SHOT_AMOUNT)
					{
						// We use ship.angle here to base the shot direction on where the ship is facing
						var p = new Projectile(ship.getGraphicMidpoint().x, ship.getGraphicMidpoint().y, ship.angle + angleIncrement, 1);
						projectiles.add(p); // Add projectile to group
						angleIncrement += (360/MULTISHOT_SHOT_AMOUNT);
					}
				}
			}
        }

		FlxG.overlap(asteroid, ship, collidePlayer);
		FlxG.overlap(asteroid, projectiles, collideProjectile); // Check for collisions between asteroids, projectiles
		// FlxG.overlap(enemy, projectiles, collideProjectile); // For when enemy is added
		}


	function collidePlayer(object1:FlxObject, object2:FlxObject):Void
	{
		// object2.setPosition(50,50);
		object2.kill();
		gameOverText.visible = true;
	}

	// Function handles projectile collision
	function collideProjectile(object1:FlxObject, object2:FlxObject):Void
	{
		// Check if the object is an Asteroid
		if (Std.isOfType(object1, Asteroid))
		{
			var a = new Asteroid();
			asteroid.add(a);

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
		multishotText.text = "Super: " + multishotCharge + "/" + MULTISHOT_CHARGE_MAX;
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

	function togglePause():Void
    {
        isPaused = !isPaused;
        pauseGroup.visible = isPaused;
    }

    function onContinue():Void
    {
    	if (isPaused) 
    	{
        	togglePause();
    	}
    }

    function onRestart():Void
    {
    	if (isPaused)
    	{
        	FlxG.resetState();
        }
    }

    function onExit():Void
    {
    	if (isPaused)
    	{
    		FlxG.sound.playMusic(null, 1, true);
        	FlxG.switchState(MenuState.new);
    	}
    }
}
