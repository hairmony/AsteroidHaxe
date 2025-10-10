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
import flixel.util.FlxTimer;
import flixel.math.FlxAngle;

class PlayState extends FlxState
{
	var ship:Player;
	var asteroid:FlxGroup;
	var projectiles:FlxGroup;
	var enemyProjectiles:FlxGroup;
	var specialProjectiles:FlxGroup; // Separate special projectiles
	var scoreText:FlxText;
	var multishotText:FlxText; // New text to track multishot
	var multishotControlsText:FlxText;
	var gameOverText:FlxText;
	public static var multiplierText:FlxText; //Set to static to be accessible from Enemy.hx
	var enemy:FlxGroup;
	var timer:FlxTimer;

	// Score tracking variables
	public var asteroidHits:Float = 0;
	public var enemyHits:Float = 0;
	public var accuracyBonus:Float = 0;
	public var score:Float = 0;
	public static var MULTIPLIER:Int = 1; //Set the multiplier to 1; Set to static to be accessible from Enemy.hx

	// Variables for the multi-shot cooldown
	public var multishotCharge:Float = 0;
	public static var MULTISHOT_CHARGE_MAX:Float = 20; // in number of objects killed
	public static var MULTISHOT_SHOT_AMOUNT:Int = 6;
	public static var ASTEROID_AMOUNT:Int = 5;

	// Variables for enemies
	public static var ENEMY_AMOUNT:Int = 4;
	public static var ENEMY_SHOT_DELAY:Float = 1.0; // Shot delay is randomized between -ve and +ve of this value
	var shotDelay:Float = 0;
	
	// Pause menu variables
	var isPaused:Bool = false;
    var pauseGroup:FlxGroup;
    var pauseText:FlxText;

	override public function create():Void
	{
		FlxG.sound.playMusic("assets/music/LevelMusic.ogg", 1, true);
		super.create();

		//Create text
		scoreText = new FlxText(25,25,0, "Score: " + score, 14); //add 5th argument as true if we are adding custom fonts
		add(scoreText);

		multishotText = new FlxText(25,45,0, "Super: " + multishotCharge + "/" + MULTISHOT_CHARGE_MAX, 14);
		add(multishotText);

		multiplierText = new FlxText(25, 65, 0, MULTIPLIER + "x", 14);
		multiplierText.visible = false;
		add(multiplierText);

		gameOverText = new FlxText(0, FlxG.height / 2, FlxG.width, "Transmission Lost", 32);
        gameOverText.alignment = CENTER;
        gameOverText.visible = false;
        add(gameOverText);

        // Ship select from save file
        var save = new FlxSave();
		save.bind("LeftAligned");

		var shipAsset:Int = 0; // Default to 0
		if (save.data.shipChoice != null)
			shipAsset = save.data.shipChoice;

		save.close();
		
		// Spawn in player
		ship = new Player(shipAsset);
		add(ship);

		// Moved player spawn to bottom of the screen
		ship.x = FlxG.width / 2;
		ship.y = FlxG.height - 50;

		//Create enemy group
		enemy = new FlxGroup();
		add(enemy);

		for(i in 0...ENEMY_AMOUNT){
			var e = new Enemy();
			enemy.add(e);
		}

		// Spawn in stationary test asteroid
		asteroid = new FlxGroup();
		add(asteroid);

		for(i in 0...ASTEROID_AMOUNT) {
			var a = new Asteroid();
			asteroid.add(a);
		}

		//Create a seperate projectiles group for enemy projectiles
		enemyProjectiles = new FlxGroup();
		add(enemyProjectiles);

		// New projectile group
		projectiles = new FlxGroup(); 
		add(projectiles);

		specialProjectiles = new FlxGroup();
		add(specialProjectiles);

		multishotControlsText = new FlxText(0, FlxG.height - 32, 0, "SPACE to Super", 12);
		multishotControlsText.alignment = CENTER;
		multishotControlsText.screenCenter(X);
		multishotControlsText.visible = false;
		add(multishotControlsText);

		//create a timer that shoots an enemy projectile every 3 seconds
		shotDelay = FlxG.random.float(-ENEMY_SHOT_DELAY, ENEMY_SHOT_DELAY) + 3;
		timer = new FlxTimer().start(shotDelay, enemyShot, 0);

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
        var btnRestart = new FlxButton(0, btnContinue.y + 25, "Restart", onRestart);
        btnRestart.screenCenter(X);
        pauseGroup.add(btnRestart);

        // Exit button
        var btnExit = new FlxButton(0, btnRestart.y + 25, "Exit", onExit);
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
			// MULTIPLIER = 1;
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
					var p = new Projectile(ship.getGraphicMidpoint().x, ship.getGraphicMidpoint().y, ship.angle - 90, false, 0);
					projectiles.add(p); // Add projectile to group
				}

				// Multishot: shoot 8 projectiles in a circle
				if (FlxG.keys.justPressed.SPACE && multishotCharge >= MULTISHOT_CHARGE_MAX)
				{
					// Reset the cooldown
					multishotCharge = 0;
					multishotControlsText.visible = false;

					var angleIncrement:Float = 0;
					for (i in 0...MULTISHOT_SHOT_AMOUNT)
					{
						// We use ship.angle here to base the shot direction on where the ship is facing
						var p = new Projectile(ship.getGraphicMidpoint().x, ship.getGraphicMidpoint().y, ship.angle + angleIncrement, false, 1);
						specialProjectiles.add(p); // Add projectile to group
						angleIncrement += (360/MULTISHOT_SHOT_AMOUNT);
					}

					updateMultishotText();
				}
			}
        }

	    // Player collision
		FlxG.overlap(asteroid, ship, collidePlayer);
		FlxG.overlap(enemy, ship, collidePlayer);
		FlxG.overlap(enemyProjectiles, ship, collidePlayer); //Check for collision between enemy projectile and player
		
		// Projectile collision
		FlxG.overlap(asteroid, projectiles, collideProjectile); // Check for collisions between asteroids, projectiles
		FlxG.overlap(enemy, projectiles, collideProjectile); // For when enemy is added
		FlxG.overlap(enemyProjectiles, specialProjectiles, collideProjectile);

		// Special Projectile collision
		FlxG.overlap(asteroid, specialProjectiles, collideProjectile); // Check for collisions between asteroids, projectiles
		FlxG.overlap(enemy, specialProjectiles, collideProjectile); // For when enemy is added
	}
 

	function collidePlayer(object1:FlxObject, object2:FlxObject):Void
	{
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
		else if (Std.isOfType(object1, Enemy))
		{
			// Add to the enemy kill count
		 	enemyHits++;

		 	var e = new Enemy();
		 	enemy.add(e);

		 	//REMOVE ENEMY FROM FLEX OBJECT TO NOT BREAK ENEMY SHOT CYCLE
		 	enemy.remove(object1);
		}

		// Add to multishot charge when object is hit
		if (multishotCharge < MULTISHOT_CHARGE_MAX)
		{
			multishotCharge++;
			updateMultishotText(); // Update the display
		}

		object1.kill();
		object2.kill();

		// Update score
		updateScoreText();
	}

	function updateMultishotText():Void
	{
		if (multishotCharge >= MULTISHOT_CHARGE_MAX)
			multishotControlsText.visible = true;
		
		multishotText.text = "Super: " + multishotCharge + "/" + MULTISHOT_CHARGE_MAX;
	}

	// Function calculates score for player
	function updateScoreText():Float
	{
		// Add code here for multiplier
		if (enemyHits % 5 == 0){
			if (MULTIPLIER < 5){
				MULTIPLIER++;
			}
			multiplierText.text = MULTIPLIER + "X";
			multiplierText.visible = true;
		}

		score = asteroidHits * 100 + enemyHits * 200; // Calculating the base score
		score *= MULTIPLIER;
		scoreText.text = "Score: " + score;

		return(score);
	}

	//I feel this can be optimized
	function enemyShot(timer:FlxTimer): Void {
		//Access all the enemy FlxGroup elements
		for(i in enemy){
			var temp:Enemy = cast(i, Enemy); //create a temporary Enemy object based of the inspected FlxGroup element
			
			//get the midpoint of the temporary enemy
			var xC:Float = temp.getGraphicMidpoint().x;
			var yC:Float = temp.getGraphicMidpoint().y;

			//calculate the difference in position using getMidpoint for the enemy and player
			var dX:Float = temp.getMidpoint().x - ship.getMidpoint().x;
			var dY:Float = temp.getMidpoint().y - ship.getMidpoint().y;

			//calculate the angle in degrees; - 180 is used to reverse the calculated angle
			var targetAng:Float = Math.atan2(dY,dX) * (180 / Math.PI) - 180;

			//Randomly adjust the shot by 2 degrees
			targetAng += FlxG.random.float(-2.0, 2.0);

			//create a new projectile with the calulated data
			var ep = new Projectile(xC,yC,targetAng, true, 2);
			enemyProjectiles.add(ep);
		}

		//reroll shot delay
		shotDelay = FlxG.random.float(-ENEMY_SHOT_DELAY, ENEMY_SHOT_DELAY) + 3;
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
        	FlxG.switchState(MenuState.new); //Run time bug
    	}
    }
}
