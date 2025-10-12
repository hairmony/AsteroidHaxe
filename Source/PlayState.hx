package;

import flixel.FlxState;
import flixel.FlxObject;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.util.FlxSpriteUtil;
import flixel.text.FlxText;
import flixel.FlxSubState;
import flixel.ui.FlxButton;
import flixel.util.FlxSave;
import flixel.util.FlxTimer;
import flixel.math.FlxAngle;
import flixel.util.FlxColor;

class PlayState extends FlxState
{
	public var ship:Player; // So Boss.hx can use it
	var asteroid:FlxGroup;
	var projectiles:FlxGroup;
	public var enemyProjectiles:FlxGroup; // Public so boss can fire projectiles in Boss.hx
	var specialProjectiles:FlxGroup; // Separate special projectiles
	var scoreText:FlxText;
	var multishotText:FlxText; // New text to track multishot
	var multishotControlsText:FlxText;
	var gameOverText:FlxText;
	var gameWonText:FlxText;
	var multiplierText:FlxText;
	var healthText:FlxText;
	var enemy:FlxGroup;
	var timer:FlxTimer;

	var fireTimer:Float = 0;
    public static var PLAYER_SHOTS_PER_SEC:Float = 6; // How many shots per second
    var fireRate = 1/PLAYER_SHOTS_PER_SEC;
    var playerHealth:Int = 3; //Tracks player health

	var isgameOver:Bool = false;

	// Score tracking variables
	public var asteroidHits:Int = 0;
	public var enemyHits:Int = 0;
	public var accuracyBonus:Float = 0;
	public var score:Float = 0;

	public static var MULTIPLIER:Int = 1; //Set the multiplier to 1; Set to static to be accessible from Enemy.hx
	public static var multiplierTimer:Float = 0;
	private static var MULTIPLIER_MAX:Int = 5;
	private static var MULTIPLIER_DECAY:Float = 1.0; // seconds per decay

	// Variables for the multi-shot cooldown
	public var multishotCharge:Float = 0;
	public static var MULTISHOT_CHARGE_MAX:Float = 20; // in number of objects killed
	public static var MULTISHOT_SHOT_AMOUNT:Int = 8;
	
	// Variables for asteroid
	public static var ASTEROID_AMOUNT:Int = 8;

	// Variables for enemies
	public static var ENEMY_AMOUNT:Int = 4;
	public static var ENEMY_SHOT_DELAY:Float = 1.0; // Shot delay is randomized between -ve and +ve of this value
	public static var ENEMY_INACCURACY:Float = 2.0; // randomly btw + and - angle
	var shotDelay:Float = 0;

	// Wave mode variables
	var boss:Boss;
	var currentWave:Int = -1;
	var enemiesToSpawn:Int = 0;
	var asteroidsToSpawn:Int = 0;
	var waveText:FlxText;
	var isSpawning:Bool = false;
	var enemiesToSpawnForWave:Int = 0;
	var asteroidsToSpawnForWave:Int = 0;

	public var FINAL_WAVE:Int = 12;
	
	// Pause menu variables
	private function pausemenu():Void
	{
		openSubState(new PauseState());
	}

	// var isPaused:Bool = false;
    // var pauseGroup:FlxGroup;
    // var pauseText:FlxText;

	override public function create():Void
	{
		MULTIPLIER = 1;
		multiplierTimer = 0;

		FlxG.sound.playMusic("assets/music/LevelMusic.ogg", 1, true);
		super.create();

		//Create text
		scoreText = new FlxText(25,25,0, "Score: " + score, 14); //add 5th argument as true if we are adding custom fonts
		add(scoreText);
		
		multiplierText = new FlxText(25, 45, 0, MULTIPLIER + "x", 14);
		multiplierText.visible = true;
		add(multiplierText);

		multishotText = new FlxText(25,65,0, "Super: " + multishotCharge + "/" + MULTISHOT_CHARGE_MAX, 14);
		add(multishotText);

		healthText = new FlxText(25,85,0, "Hits Left: " + playerHealth, 14);
		add(healthText);

		gameOverText = new FlxText(0, FlxG.height / 2, FlxG.width, "Transmission Lost", 32);
        gameOverText.alignment = CENTER;
        gameOverText.visible = false;
        add(gameOverText);

        gameWonText = new FlxText(0, FlxG.height / 2, FlxG.width, "Sector Secured", 32);
		gameWonText.alignment = CENTER;
		gameWonText.visible = false;
		add(gameWonText);

		waveText = new FlxText(0, FlxG.height / 2 - 50, FlxG.width, "", 16);
		waveText.alignment = CENTER;
		add(waveText);

		// New projectile group
		projectiles = new FlxGroup(); 
		add(projectiles);

		specialProjectiles = new FlxGroup();
		add(specialProjectiles);

        // Ship select from save file
        var save = new FlxSave();
		save.bind("LeftAliened");

		var shipAsset:Int = 0; // Default to 0
		if (save.data.shipChoice != null)
			shipAsset = save.data.shipChoice;

		save.close();
		
		// Spawn in player
		ship = new Player(shipAsset);
		add(ship);

		// Moved player spawn to bottom of the screen
		ship.x = FlxG.width / 2 - (ship.width / 2);
		ship.y = FlxG.height - 50;

		//Create enemy group
		enemy = new FlxGroup();
		add(enemy);

		// for(i in 0...ENEMY_AMOUNT){
		// 	var e = new Enemy();
		// 	enemy.add(e);
		// }

		// Spawn in stationary test asteroid
		asteroid = new FlxGroup();
		add(asteroid);

		// for(i in 0...ASTEROID_AMOUNT) {
		// 	var a = new Asteroid();
		// 	asteroid.add(a);
		// }

		//Create a seperate projectiles group for enemy projectiles
		enemyProjectiles = new FlxGroup();
		add(enemyProjectiles);

		multishotControlsText = new FlxText(0, FlxG.height - 32, 0, "SPACE to Super", 12);
		multishotControlsText.alignment = CENTER;
		multishotControlsText.screenCenter(X);
		multishotControlsText.visible = false;
		add(multishotControlsText);

		//create a timer that shoots an enemy projectile every 3 seconds
		shotDelay = FlxG.random.float(-ENEMY_SHOT_DELAY, ENEMY_SHOT_DELAY) + 3;
		timer = new FlxTimer().start(shotDelay, enemyShot, 0);

		// Wave start
		startWave();
		updateScoreText();

		// PAUSE MENU CODE

		// Create pause menu group but keep it hidden initially
        // pauseGroup = new FlxGroup();
        // pauseGroup.visible = false;
        // add(pauseGroup);

	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);

		//Prevents the player from going offscreen
		FlxSpriteUtil.cameraBound(ship);

		multiplierText.text = MULTIPLIER + "x"; // Always show
		multiplierText.visible = true;

		if (MULTIPLIER == MULTIPLIER_MAX)
	    {
	        multiplierText.color = FlxColor.RED; // Set to red when at max
	    }
	    else
	    {
	        multiplierText.color = FlxColor.WHITE; // Set back to white otherwise
	    }

		// Debug controls
		if (FlxG.keys.justPressed.RBRACKET) // press ] kill all enemies
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
		if (FlxG.keys.justPressed.LBRACKET) // Press [ respawn
		{
			ship.reset(FlxG.width / 2, FlxG.height - 50);
			gameOverText.visible = false;
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
		
		// Reset button
		if (FlxG.keys.justPressed.R)
		{
			// MULTIPLIER = 1;
			FlxG.resetState(); // Reset with R key
		}


		if (FlxG.keys.justPressed.ESCAPE)
        {
        	pausemenu();
        }

        // Only run gameplay updates if NOT paused
        // your normal gameplay code goes here (player movement, collisions, etc.)
        fireTimer += elapsed;

        if (ship.alive) // Ship controls disabled if ship is dead
		{
			// Default: shoot 1 projectile with LMB or hold LMB
			if ((FlxG.mouse.pressed && fireTimer >= fireRate) || FlxG.mouse.justPressed)
			{
				fireTimer = 0;

				var p = new Projectile(ship.getGraphicMidpoint().x, ship.getGraphicMidpoint().y, ship.angle - 90, 0, 0);
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
					var p = new Projectile(ship.getGraphicMidpoint().x, ship.getGraphicMidpoint().y, ship.angle + angleIncrement, 0, 1);
					specialProjectiles.add(p); // Add projectile to group
					angleIncrement += (360/MULTISHOT_SHOT_AMOUNT);
				}

				updateMultishotText();
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

		// Boss collision
		if (boss != null && boss.alive)
		{
			FlxG.overlap(boss, projectiles, collideBoss);
			FlxG.overlap(boss, specialProjectiles, collideBoss);
			FlxG.overlap(boss, ship, collidePlayer);
		}
	}
 

	function collidePlayer(object1:FlxObject, object2:FlxObject):Void
	{
		//always update player health
		playerHealth--;
		healthText.text = "Hits Left: " + playerHealth;

		if (playerHealth < 1){
			FlxG.camera.flash(0xFFFF0000, 2.0); // flash red
			object2.kill();
			gameWonText.visible = false; // If player dies after beating the boss
			gameOverText.visible = true;
		}
		else { //When player hasn't run out of health
			object1.kill(); //Get rid of collided object to not cause lasting bugs
		}
		
	}

	// Function handles projectile collision
	function collideProjectile(object1:FlxObject, object2:FlxObject):Void
	{
		object1.kill();
		object2.kill();

		var pointsAdd:Int = 0;

		// Check if the object is an Asteroid
		if (Std.isOfType(object1, Asteroid))
		{
			// var a = new Asteroid();
			// asteroid.add(a);
			// Add to asteroid kill count
			asteroidHits++;
			pointsAdd = 100;
		}
		// Add in when we have Enemy objects
		else if (Std.isOfType(object1, Enemy))
		{
			// Add to the enemy kill count
		 	enemyHits++;
		 	updateMultiplier();

		 	pointsAdd = 200;

		 	// var e = new Enemy();
		 	// enemy.add(e);

		 	//REMOVE ENEMY FROM FLEX OBJECT TO NOT BREAK ENEMY SHOT CYCLE
		 	// enemy.remove(object1);
		}

		// Add to multishot charge when object is hit
		if (multishotCharge < MULTISHOT_CHARGE_MAX)
		{
			multishotCharge++;
			updateMultishotText(); // Update the display
		}

		score += pointsAdd * MULTIPLIER;

		// Update score
		updateScoreText();
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

			playerHealth++;
			healthText.text = "Hits Left: " + playerHealth;

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
	        asteroidsToSpawn = 32;
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
		// score = asteroidHits * 100 + enemyHits * 200; // Calculating the base score
		// score *= MULTIPLIER;

		// Moved score calculation logic to collision function

		scoreText.text = "Score: " + score;
		return(score);
	}

	function updateMultiplier()
	{
		// Increase multiplier, up to max
	    if(MULTIPLIER < MULTIPLIER_MAX)
	    {
	        MULTIPLIER++;
	    }
	    
	    multiplierTimer = 0;
	}

	//I feel this can be optimized
	function enemyShot(timer:FlxTimer): Void {
		//Access all the enemy FlxGroup elements
		for(i in enemy){
			var temp:Enemy = cast(i, Enemy); //create a temporary Enemy object based of the inspected FlxGroup element
			
			if (temp.alive)
			{
				//get the midpoint of the temporary enemy
				var xC:Float = temp.getGraphicMidpoint().x;
				var yC:Float = temp.getGraphicMidpoint().y;

				//calculate the difference in position using getMidpoint for the enemy and player
				var dX:Float = temp.getMidpoint().x - ship.getMidpoint().x;
				var dY:Float = temp.getMidpoint().y - ship.getMidpoint().y;

				//calculate the angle in degrees; - 180 is used to reverse the calculated angle
				var targetAng:Float = Math.atan2(dY,dX) * (180 / Math.PI) - 180;

				//Randomly adjust the shot by 2 degrees
				targetAng += FlxG.random.float(-ENEMY_INACCURACY, ENEMY_INACCURACY);

				//create a new projectile with the calulated data
				var ep = new Projectile(xC,yC,targetAng, 1, 2);
				enemyProjectiles.add(ep);
			}
		}

		//reroll shot delay
		shotDelay = FlxG.random.float(-ENEMY_SHOT_DELAY, ENEMY_SHOT_DELAY) + 3;
	}


	// function togglePause():Void
    // {
    //     isPaused = !isPaused;
    //     pauseGroup.visible = isPaused;
    // }
}