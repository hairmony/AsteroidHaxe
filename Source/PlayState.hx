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

<<<<<<< Updated upstream
=======
	var fireTimer:Float = 0;
    public static var PLAYER_SHOTS_PER_SEC:Float = 6; // How many shots per second
    var fireRate = 1/PLAYER_SHOTS_PER_SEC;

	public static var PLAYER_HEALTH_MAX:Int = 3; //Tracks player health
    var playerHealth:Int = PLAYER_HEALTH_MAX; 

	var isgameOver:Bool = false;

>>>>>>> Stashed changes
	// Score tracking variables
	public var asteroidHits:Float = 0;
	public var enemyHits:Float = 0;
	public var accuracyBonus:Float = 0;
	public var score:Float = 0;
	public static var MULTIPLIER:Int = 1; //Set the multiplier to 1; Set to static to be accessible from Enemy.hx

	// Variables for the multi-shot cooldown
	public var multishotCharge:Float = 0;
	public static var MULTISHOT_CHARGE_MAX:Float = 20; // in number of objects killed
<<<<<<< Updated upstream
	public static var MULTISHOT_SHOT_AMOUNT:Int = 6;
	public static var ASTEROID_AMOUNT:Int = 5;
=======
	public static var MULTISHOT_SHOT_AMOUNT:Int = 8;
	public var blinkTimer:Float = 0;
	
	// Variables for asteroid
	public static var ASTEROID_AMOUNT:Int = 8;
>>>>>>> Stashed changes

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

<<<<<<< Updated upstream
		multiplierText = new FlxText(25, 65, 0, MULTIPLIER + "X", 16);
		multiplierText.visible = false;
		add(multiplierText);

=======
		healthText = new FlxText(25,85,0, "HP: " + playerHealth, 14);
		add(healthText);
>>>>>>> Stashed changes

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
		
		// Haxe
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

<<<<<<< Updated upstream
=======
		multiplierText.text = MULTIPLIER + "x"; // Always show
		multiplierText.visible = true;

		if (MULTIPLIER == MULTIPLIER_MAX)
	    {
	        multiplierText.color = FlxColor.ORANGE; // Set to orange when at max
	        scoreText.color = FlxColor.ORANGE;
	    }
	    else
	    {
	        multiplierText.color = FlxColor.WHITE; // Set back to white otherwise
	        scoreText.color = FlxColor.WHITE;
	    }

	    // multishotControlsText will blink when visible
	    if (multishotControlsText.visible == true)
	    {
	        blinkTimer += elapsed; // increment every frame
	        multishotControlsText.alpha = 0.3 + 0.7 * (Math.sin(blinkTimer * 6) * 0.5 + 0.5);
	    }
	    else
	    {
	        multishotControlsText.alpha = 1;
	        blinkTimer = 0;
	    }

		// Debug controls
		if (FlxG.keys.justPressed.PERIOD) // press ] kill all enemies
		{
		for (e in enemy)
		    {
		        e.kill(); // Kill all enemies
		    }
		    for (a in asteroid)
		    {
		    	a.kill();
		    }
		    if (boss != null && boss.alive)
		    {
		        boss.kill(); // Kill all bosses
		    }
		    isWaveComplete();
		}
		if (FlxG.keys.justPressed.COMMA) // Press [ respawn
		{
			ship.reset(FlxG.width / 2 - (ship.width / 2), FlxG.height - 50);
			playerHealth = PLAYER_HEALTH_MAX;
			updateHealthText();
			gameOverText.visible = false;
		}
		if (FlxG.keys.justPressed.SLASH) // Press [ respawn
		{
			ship.isInvincible = !ship.isInvincible;
		}

		// Handle multiplier countdown
		if(MULTIPLIER > 1)
		{
		    // multiplierText.text = MULTIPLIER + "x";
		    multiplierTimer += elapsed; // increment timer
		    
		    if (multiplierTimer >= MULTIPLIER_DECAY)
		    {
		    	MULTIPLIER--;
		    	multiplierTimer = 0;
		    }
		}
		
>>>>>>> Stashed changes
		// Reset button
		if (FlxG.keys.justPressed.R)
		{
			MULTIPLIER = 1;
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
<<<<<<< Updated upstream
					var p = new Projectile(ship.getGraphicMidpoint().x, ship.getGraphicMidpoint().y, ship.angle - 90, false, 0);
					projectiles.add(p); // Add projectile to group
=======
					// We use ship.angle here to base the shot direction on where the ship is facing
					var p = new Projectile(ship.getGraphicMidpoint().x, ship.getGraphicMidpoint().y, ship.angle + angleIncrement, 0, 1);
					specialProjectiles.add(p); // Add projectile to group
					p.bulletPenetration = 3;
					angleIncrement += (360/MULTISHOT_SHOT_AMOUNT);
>>>>>>> Stashed changes
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

					multishotText.text = "Super: " + multishotCharge + "/" + MULTISHOT_CHARGE_MAX;
				}
			}
<<<<<<< Updated upstream
        }
=======

			if (FlxG.keys.justReleased.SHIFT && !ship.isDodging)
			{
			    ship.isDodging = true;
			    ship.dodgeTimer = 0;

			    ship.isInvincible = true; // for collidePlayer function
			}
		}
>>>>>>> Stashed changes

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
<<<<<<< Updated upstream
		object2.kill();
		gameOverText.visible = true;
=======
		if (ship.isDodging || ship.isInvincible)
			return;

		//always update player health
		playerHealth--;

		ship.color = 0xFFFF0000; // Red
		new FlxTimer().start(0.1, function(t) { ship.color = 0xFFFFFFFF; }); // Flash if player hit

		updateHealthText();
		// healthText.text = "Hits Left: " + playerHealth;

		if (playerHealth <= 0){
			FlxG.camera.flash(0xFFFF0000, 2.0); // flash red
			object2.kill();
			gameWonText.visible = false; // If player dies after beating the boss
			gameOverText.visible = true;
		}
		else { //When player hasn't run out of health
			object1.kill(); //Get rid of collided object to not cause lasting bugs
		}
		
>>>>>>> Stashed changes
	}

	// Function handles projectile collision
	function collideProjectile(object1:FlxObject, object2:FlxObject):Void
	{
<<<<<<< Updated upstream
=======
		// object1.kill();
		// object2.kill();

		var pointsAdd:Int = 0;

		if (Std.isOfType(object1, Projectile))
	    {	
	    	var p1 = cast(object1, Projectile);
	        if (p1.bulletPenetration > 0)
	            p1.bulletPenetration--;
	        else
	            p1.kill();
	    }
	    else 
	    	object1.kill();

	    if (Std.isOfType(object2, Projectile))
	    {
	        var p2 = cast(object2, Projectile);
	        if (p2.bulletPenetration > 0)
	            p2.bulletPenetration--;
	        else
	            p2.kill();
	    }
	    else
	    	object2.kill();

>>>>>>> Stashed changes
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
<<<<<<< Updated upstream
=======
		isWaveComplete();
	}

	function collideBoss(object1:FlxObject, object2:FlxObject):Void
	{
		var boss:Boss = cast(object1, Boss);
		var projectile:Projectile = cast(object2, Projectile);

		projectile.kill();

		boss.hp--;

		// This makes the boss flash when taking damage!
		boss.color = 0xFFFF0000;
		new FlxTimer().start(0.1, function(t) { boss.color = 0xFFFFFFFF; });

		if (boss.hp <= 0)
		{
			FlxG.camera.flash(0xFFFFFFFF, 1.0); // Flash white
			boss.kill();

			score += 5000 * MULTIPLIER; // Boss worth 5000 (?)
			multishotCharge = MULTISHOT_CHARGE_MAX; // Boss fully recharges multishot charge

			updateMultishotText();
			updateScoreText();

			playerHealth += PLAYER_HEALTH_MAX;
			healthText.text = "HP: " + playerHealth;

			if (currentWave == FINAL_WAVE)
			{
				gameWonText.visible = true;
	   			isgameOver = true;
			}
			else 
			{
				isWaveComplete();
			}
		}
	}

	function startWave():Void
	{
		if (isgameOver)
			return;

		currentWave++;
		isSpawning = true;

		// Flash wave text on screen
		waveText.visible = true;
		new FlxTimer().start(2.0, function(timer:FlxTimer){waveText.visible = false;});

		enemiesToSpawn = 0;
		asteroidsToSpawn = 0;

		if (currentWave == 0)
	    {
	        enemiesToSpawn = 0;
	        asteroidsToSpawn = 10;
	        waveText.text = "Shoot the Asteroids!";
	    }
	    if (currentWave == 1)
	    {
	        enemiesToSpawn = 2;
	        asteroidsToSpawn = 10;
	        waveText.text = "Wave " + currentWave;
	    }
	    else if (currentWave == 2)
	    {
	        enemiesToSpawn = 4;
	        asteroidsToSpawn = 12;
	        waveText.text = "Wave " + currentWave;
	    }
	    else if (currentWave == 3)
	    {
	        enemiesToSpawn = 6;
	        asteroidsToSpawn = 24;
	        waveText.text = "Wave " + currentWave;
	    }
	    else if (currentWave == 4)
	    {
	        enemiesToSpawn = 10;
	        asteroidsToSpawn = 32;
	        waveText.text = "Wave " + currentWave;
	    }
	    else if (currentWave == 5) // Boss phase 1
	    {
	    	enemiesToSpawn = 16;
	        asteroidsToSpawn = 64;
	        waveText.text = "Asteroid shower!";
	    }
	    else if (currentWave == 6)
	    {
	        enemiesToSpawn = 0;
	        asteroidsToSpawn = 0;
	        waveText.text = "Enemy Leader Inbound...";
	        spawnBoss(0, 0);
	    }
	    else if (currentWave == 7)
	    {
	        enemiesToSpawn = 16;
	        asteroidsToSpawn = 32;
	        waveText.text = "Wave " + currentWave;
	    }
	    else if (currentWave == 8)
	    {
	        enemiesToSpawn = 24;
	        asteroidsToSpawn = 24;
	        waveText.text = "Wave " + currentWave;
	    }
	    else if (currentWave == 9)
	    {
	        enemiesToSpawn = 32;
	        asteroidsToSpawn = 12;
	        waveText.text = "Wave " + currentWave;
	    }
	    else if (currentWave == 10)
	    {
	        enemiesToSpawn = 48;
	        asteroidsToSpawn = 12;
	        waveText.text = "Wave " + currentWave;
	    }
	    else if (currentWave == 11)
	    {
	        enemiesToSpawn = 70;
	        asteroidsToSpawn = 0;
	        waveText.text = "Enemy Territory!";
	    }
	    else if (currentWave == FINAL_WAVE) // Boss Wave
	    {
	        enemiesToSpawn = 0;
	        asteroidsToSpawn = 32;
	        waveText.text = "Enemy Leader Awakened...";
	        spawnBoss(0, 1);
	    }
	    // else // when game ends
	    // {
	    //     if (boss == null || !boss.alive)
	    //     {
	    //         gameWonText.visible = true;
	    //         isgameOver = true;
	    //     }
	    // }

		// Spawn enemies and asteroids
		if (enemiesToSpawn > 0) // for some reason FlxTimer loops inf times if the value is 0
		{
			new FlxTimer().start(0.5, function(timer:FlxTimer)
			{
			    if (!PauseState.isPaused)
			    	enemy.add(new Enemy());
			}, enemiesToSpawn);
		}

		// Add asteroids staggered
		if (asteroidsToSpawn > 0) // for some reason FlxTimer loops inf times if the value is 0
		{
			new FlxTimer().start(0.5, function(timer:FlxTimer)
			{
				if (!PauseState.isPaused)
			    	asteroid.add(new Asteroid());
			}, asteroidsToSpawn);
		}

		// Calculating the total spawn time to spawn in everything
		var enemySpawnDuration = 0.5 * enemiesToSpawn;
		var asteroidSpawnDuration = 0.5 * asteroidsToSpawn;
		var totalSpawnTime = Math.max(enemySpawnDuration, asteroidSpawnDuration);

		if (totalSpawnTime > 0)
		{
			new FlxTimer().start(totalSpawnTime + 0.1, function(timer:FlxTimer)
			{
				isSpawning = false;
			});
		}
		else
		{
			// If nothing is spawning (like a boss wave), set the flag immediately.
			isSpawning = false;
		}
	}

	function spawnBoss(assetID:Int = 0, bossType:Int = 0):Void
	{
		boss = new Boss(0, -100, assetID, bossType); // Slightly off the top of the screen
		add(boss);

		boss.x = (FlxG.width - boss.width) / 2;

		flixel.tweens.FlxTween.tween(boss, { y: 50 }, 2.0); // Tweening exists!
	}

	function isWaveComplete():Void
	{
		if (isSpawning || isgameOver)
			return;

		var isEnemiesDead = (enemiesToSpawn == 0) || (enemy.countLiving() == 0);
    	var isAsteroidsDead = (asteroidsToSpawn == 0) || (asteroid.countLiving() <= 4);

		if (ship.alive && isEnemiesDead && isAsteroidsDead && (boss == null || !boss.alive))
		{
			startWave();
		}
>>>>>>> Stashed changes
	}

	function updateMultishotText():Void
	{
		if (multishotCharge >= MULTISHOT_CHARGE_MAX)
		{
			multishotControlsText.visible = true;
		}
		
		multishotText.text = "Super: " + multishotCharge + "/" + MULTISHOT_CHARGE_MAX;
	}

	// Function calculates score for player
	function updateScoreText():Float
	{
		// Currently DOES NOT track multiplier bonuses
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

<<<<<<< Updated upstream
		return(score);
=======
	function updateHealthText()
	{
		healthText.text = "HP: " + playerHealth;
	}

	function updateMultiplier()
	{
		// Increase multiplier, up to max
	    if(MULTIPLIER < MULTIPLIER_MAX)
	    {
	        MULTIPLIER++;
	    }
	    
	    multiplierTimer = 0;
>>>>>>> Stashed changes
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
