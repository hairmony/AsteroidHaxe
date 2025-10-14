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
import flixel.addons.display.FlxBackdrop;

class PlayState extends FlxState
{
	public var ship:Player; // So Boss.hx can use it
	var asteroid:FlxGroup;
	var projectiles:FlxGroup;
	public var enemyProjectiles:FlxGroup; // Public so boss can fire projectiles in Boss.hx
	var specialProjectiles:FlxGroup; // Separate special projectiles
	var scoreText:FlxText;
	var multishotText:FlxText; // New text to track multishot
	var controlsText:FlxText;
	var gameOverText:FlxText;
	var gameWonText:FlxText;
	public var multiplierText:FlxText;
	var healthText:FlxText;
	var enemy:FlxGroup;
	var timer:FlxTimer;

	var fireTimer:Float = 0;
    public static var PLAYER_SHOTS_PER_SEC:Float = 6; // How many shots per second
    var fireRate = 1/PLAYER_SHOTS_PER_SEC;

    public static var PLAYER_HEALTH_MAX:Int = 3; 
    var playerHealth:Int = 3; //Tracks player health

    public static var DEATH_ANIMATION_DURATION:Float = 0.4; // To play animation, number of frames/Frame rate

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
	public static var MULTISHOT_CHARGE_MAX:Float = 20; //20 in number of objects killed
	public static var MULTISHOT_SHOT_AMOUNT:Int = 8; //8
	public var blinkTimer:Float = 0;

	public static var BULLET_PENETRATION:Int = 3; //3, Bullet pen amount for special projectile
	
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
	public static var SPAWN_RATE:Float = 0.5; //0.5

	private var backdrop:FlxBackdrop;
	
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

		backdrop = new FlxBackdrop("assets/images/LevelBackground.png");
        add(backdrop);
        backdrop.velocity.set(0, 50); 
        // backdrop.scale.set(1.2,1.2); 

		//Create text
		scoreText = new FlxText(25,25,0, "Score: " + score, 14); //add 5th argument as true if we are adding custom fonts
		add(scoreText);
		
		multiplierText = new FlxText(25, 45, 0, MULTIPLIER + "x", 14);
		multiplierText.visible = true;
		add(multiplierText);

		multishotText = new FlxText(25,65,0, "Super: " + multishotCharge + "/" + MULTISHOT_CHARGE_MAX, 14);
		add(multishotText);

		healthText = new FlxText(25,85,0, "HP: " + playerHealth, 14);
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

		controlsText = new FlxText(0, FlxG.height - 32, 0, "SPACE to Super", 12);
		controlsText.alignment = CENTER;
		controlsText.screenCenter(X);
		controlsText.visible = false;
		add(controlsText);

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
	        multiplierText.color = FlxColor.ORANGE; // Set to orange when at max
	        scoreText.color = FlxColor.ORANGE;
	    }
	    else
	    {
	        multiplierText.color = FlxColor.WHITE; // Set back to white otherwise
	        scoreText.color = FlxColor.WHITE;
	    }

	    // controlsText will blink when visible
	    if (controlsText.visible == true)
	    {
	        blinkTimer += elapsed; // increment every frame
	        controlsText.alpha = 0.3 + 0.7 * (Math.sin(blinkTimer * 6) * 0.5 + 0.5);
	    }
	    else
	    {
	        controlsText.alpha = 1;
	        blinkTimer = 0;
	    }

		// Debug controls
		if (FlxG.keys.justPressed.PERIOD) // press . kill all enemies
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
		if (FlxG.keys.justPressed.COMMA) // Press , respawn
		{
			ship.reset(FlxG.width / 2 - (ship.width / 2), FlxG.height - 50);
			playerHealth = PLAYER_HEALTH_MAX;
			updateHealthText();
			gameOverText.visible = false;
		}
		if (FlxG.keys.justPressed.SLASH) // Press / for God mode
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
		
		// Reset button
		if (FlxG.keys.justPressed.R)
		{
			// MULTIPLIER = 1;
			controlsText.text = "SPACE to SUPER";
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
				FlxG.sound.play("assets/sounds/ShootPlayer.ogg", 0.4, false);

				fireTimer = 0;

				var p = new Projectile(ship.getGraphicMidpoint().x, ship.getGraphicMidpoint().y, ship.angle - 90, 0, 0);
				projectiles.add(p); // Add projectile to group
			}

			// Multishot: shoot 8 projectiles in a circle
			if (FlxG.keys.justPressed.SPACE && multishotCharge >= MULTISHOT_CHARGE_MAX)
			{
				FlxG.sound.play("assets/sounds/ShootSpecial.ogg", 0.4, false);

				// Reset the cooldown
				multishotCharge = 0;
				controlsText.visible = false;

				var angleIncrement:Float = 0;
				for (i in 0...MULTISHOT_SHOT_AMOUNT)
				{
					// We use ship.angle here to base the shot direction on where the ship is facing
					var p = new Projectile(ship.getGraphicMidpoint().x, ship.getGraphicMidpoint().y, ship.angle + angleIncrement, 0, 1);
					specialProjectiles.add(p); // Add projectile to group
					p.bulletPenetration = BULLET_PENETRATION;
					angleIncrement += (360/MULTISHOT_SHOT_AMOUNT);
				}

				updateMultishotText();
			}

			if ((FlxG.keys.justReleased.SHIFT || FlxG.mouse.justReleasedRight) && !ship.isDodging)
			{
				FlxG.sound.play("assets/sounds/Dodge.ogg", 0.4, false);

			    ship.isDodging = true;
			    ship.dodgeTimer = 0;

			    ship.isInvincible = true; // for collidePlayer function
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
 

	function collidePlayer(object1:FlxSprite, object2:FlxSprite):Void
	{

		if (ship.isDodging || ship.isInvincible)
			return;

		switch (Type.getClass(object1))
		{
		case Asteroid:
	        var env:Asteroid = cast object1;
	        if (!env.isDead) {
	            // deduct player health once
	            playerHealth--;
				ship.color = 0xFFFF0000; // Red
				new FlxTimer().start(0.1, function(t) { ship.color = 0xFFFFFFFF; }); // Flash if player hit

			}
			else return;

        	updateHealthText();

	        // handle player death
	        if (playerHealth < 1) {
	            FlxG.camera.flash(0xFFFF0000, 2.0);
	            object2.kill();
	            FlxG.sound.play("assets/sounds/DeathEnemy2.ogg", 0.4, false);

	            controlsText.text = "R to Restart";
				controlsText.visible = true;
				controlsText.alignment = CENTER;
				controlsText.screenCenter(X);

	            gameWonText.visible = false;
	            gameOverText.visible = true;
	        }
	        else
	        {
	            // Death animation
	            env.isDead = true;
	            env.animation.play("death");
	            object1.kill();
	            FlxG.sound.play("assets/sounds/ExplodeAsteroid.ogg", 0.4, false);

		        object1.exists = true; 
	            new FlxTimer().start(0.15, function(timer:FlxTimer){ object1.exists = false; });
	        }
    
	    case Enemy: 
	        var e:Enemy = cast object1;
	        if (!e.isDead) 
	        {
	            playerHealth--;
				ship.color = 0xFFFF0000; // Red
				new FlxTimer().start(DEATH_ANIMATION_DURATION, function(t) { ship.color = 0xFFFFFFFF; }); // Flash if player hit

	        }
	        else return;

	            updateHealthText();

	        if (playerHealth < 1) 
	        {
	            FlxG.camera.flash(0xFFFF0000, 2.0);
	            object2.kill();
	            FlxG.sound.play("assets/sounds/DeathEnemy2.ogg", 0.4, false);

	            controlsText.text = "R to Restart";
				controlsText.visible = true;
				controlsText.alignment = CENTER;
				controlsText.screenCenter(X);

	            gameWonText.visible = false;
	            gameOverText.visible = true;
	        } else 
	        {
	            e.isDead = true;
	            e.animation.play("death");
	            object1.kill();
	            FlxG.sound.play("assets/sounds/ExplodeEnemy.ogg", 0.4, false);

	        	object1.exists = true; 
	            new FlxTimer().start(DEATH_ANIMATION_DURATION, function(timer:FlxTimer){ object1.exists = false; });
	        }
	        
	    case Projectile: 
	    	playerHealth--;
			ship.color = 0xFFFF0000; // Red
			new FlxTimer().start(0.1, function(t) { ship.color = 0xFFFFFFFF; }); // Flash if player hit
	    	updateHealthText();
	    	if (playerHealth < 1) {
	    		FlxG.camera.flash(0xFFFF0000, 2.0);
	    		object2.kill();

	    		controlsText.text = "R to Restart";
				controlsText.visible = true;
				controlsText.alignment = CENTER;
				controlsText.screenCenter(X);

	    		gameWonText.visible = false;
	    		gameOverText.visible = true;

	            } else 
	            {
	                object1.kill(); // projectiles just disappear, no animation
	            }
	        }
	    }


	// Function handles projectile collision
	function collideProjectile(object1:FlxObject, object2:FlxObject):Void
	{
		var pointsAdd:Int = 0;

		switch (Type.getClass(object1))
		{
			case Asteroid:
			var env:Asteroid = cast object1;
			if (!env.isDead)
			{
		        env.isDead = true;
		        env.animation.play("death");
		        FlxG.sound.play("assets/sounds/ExplodeAsteroid.ogg", 0.4, false);
		        object1.kill();
		        object1.exists = true; 
		        new FlxTimer().start(DEATH_ANIMATION_DURATION, function(timer:FlxTimer){ object1.exists = false; });

				pointsAdd = 200;
				asteroidHits++;
			} 
			else return;

	        case Enemy: 
	        var env:Enemy = cast object1;
        	if (!env.isDead) 
        	{
		        env.isDead = true;
		        env.animation.play("death");
		        FlxG.sound.play("assets/sounds/ExplodeEnemy.ogg", 0.4, false);
		        object1.kill();
		        object1.exists = true; 
		        new FlxTimer().start(DEATH_ANIMATION_DURATION, function(timer:FlxTimer){ object1.exists = false; });

				pointsAdd = 100;
				enemyHits++;
				updateMultiplier();
			}
			else return;

	        case Projectile:
		}

		if (Std.isOfType(object1, Projectile))
	    {	
	    	var p1 = cast(object1, Projectile);
	        if (p1.bulletPenetration > 0)
	            p1.bulletPenetration--;
	        else
	            p1.kill();
	    }
	    // else 
	    // 	object1.kill();

	    if (Std.isOfType(object2, Projectile))
	    {
	        var p2 = cast(object2, Projectile);
	        if (p2.bulletPenetration > 0)
	            p2.bulletPenetration--;
	        else
	            p2.kill();
	    }
	    // else
	    // 	object2.kill();

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
			FlxG.sound.play("assets/sounds/DeathBoss.ogg", 0.4, false);

			FlxG.camera.flash(0xFFFFFFFF, 1.0); // Flash white
			boss.kill();

			score += 5000 * MULTIPLIER; // Boss worth 5000 (?)
			multishotCharge = MULTISHOT_CHARGE_MAX; // Boss fully recharges multishot charge

			updateMultishotText();
			updateScoreText();

			playerHealth++;
			updateHealthText();

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
	        enemiesToSpawn = 0; //0
	        asteroidsToSpawn = 12;
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
	        asteroidsToSpawn = 12;
	        waveText.text = "Wave " + currentWave;
	    }
	    else if (currentWave == 4)
	    {
	        enemiesToSpawn = 12;
	        asteroidsToSpawn = 12;
	        waveText.text = "Wave " + currentWave;
	    }
	    else if (currentWave == 5) // Boss phase 1
	    {
	    	enemiesToSpawn = 16;
	        asteroidsToSpawn = 16;
	        waveText.text = "Wave " + currentWave;
	    }
	    else if (currentWave == 6)
	    {
	        enemiesToSpawn = 0;
	        asteroidsToSpawn = 12;
	        waveText.text = "Enemy Leader Inbound...";
	        spawnBoss(0, 1);
	    }
	    else if (currentWave == 7)
	    {
	        enemiesToSpawn = 16;
	        asteroidsToSpawn = 24;
	        waveText.text = "Wave " + (currentWave - 1); // Don't count BOSS as a wave
	    }
	    else if (currentWave == 8)
	    {
	        enemiesToSpawn = 24;
	        asteroidsToSpawn = 24;
	        waveText.text = "Wave " + (currentWave - 1);
	    }
	    else if (currentWave == 9)
	    {
	        enemiesToSpawn = 32;
	        asteroidsToSpawn = 12;
	        waveText.text = "Wave " + (currentWave - 1);
	    }
	    else if (currentWave == 10)
	    {
	        enemiesToSpawn = 48;
	        asteroidsToSpawn = 12;
	        waveText.text = "Wave " + (currentWave - 1);
	    }
	    else if (currentWave == 11)
	    {
	        enemiesToSpawn = 80;
	        asteroidsToSpawn = 0;
	        waveText.text = "Enemy Territory!";
	    }
	    else if (currentWave == FINAL_WAVE) // Boss Wave
	    {
	        enemiesToSpawn = 0;
	        asteroidsToSpawn = 12;
	        waveText.text = "Enemy Leader Awakened...";
	        spawnBoss(0, 0);
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
			new FlxTimer().start(SPAWN_RATE, function(timer:FlxTimer)
			{
			    if (!PauseState.isPaused)
			    	enemy.add(new Enemy());
			}, enemiesToSpawn);
		}

		// Add asteroids staggered
		if (asteroidsToSpawn > 0) // for some reason FlxTimer loops inf times if the value is 0
		{
			new FlxTimer().start(SPAWN_RATE, function(timer:FlxTimer)
			{
				if (!PauseState.isPaused)
			    	asteroid.add(new Asteroid());
			}, asteroidsToSpawn);
		}

		// Calculating the total spawn time to spawn in everything
		var enemySpawnDuration = SPAWN_RATE * enemiesToSpawn;
		var asteroidSpawnDuration = SPAWN_RATE * asteroidsToSpawn;
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
			controlsText.visible = true;
		
		multishotText.text = "Super: " + multishotCharge + "/" + MULTISHOT_CHARGE_MAX;
	}

	function updateHealthText():Void
	{
		healthText.text = "HP: " + playerHealth;
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
		if (PauseState.isPaused)
			return;

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
				FlxG.sound.play("assets/sounds/ShootEnemy.ogg", 0.4, false);
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