package;

import flixel.FlxState;
import flixel.ui.FlxButton;
import flixel.FlxG;
import flixel.FlxSubState;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.util.FlxSave;
import lime.system.System;
import flixel.util.FlxColor;
import flixel.addons.ui.FlxSlider;

class MenuState extends FlxState
{
	var bg:FlxSprite;
	var titleText:FlxText; // Variable for the title

	// var rulesPanel:FlxSprite;
	var rulesText:FlxText;

	var creditsPanel:FlxSprite;
	var creditsText:FlxText;
	var creditsScrollSpeed:Float = 30; // pixels per second
	var creditsActive:Bool = false;

	public static var padding:Float = 10;

	//Options menu
	private function optionsMenu():Void
	{
		openSubState(new OptionsState());
	}

	function scaleBackgroundToCover(sprite:FlxSprite, targetWidth:Int, targetHeight:Int):Void
    {
        var originalWidth = sprite.graphic.bitmap.width;
        var originalHeight = sprite.graphic.bitmap.height;

        var scaleX:Float = targetWidth / originalWidth;
        var scaleY:Float = targetHeight / originalHeight;

        // Use the larger scale to ensure full coverage (might crop image)
        var scale:Float = Math.max(scaleX, scaleY);

        sprite.scale.set(scale, scale);
        sprite.updateHitbox();
    }

	override public function create()
	{
		super.create();

		FlxG.sound.playMusic("assets/music/MenuMusic.ogg", 0.5, true);

		bg = new FlxSprite();
        bg.loadGraphic("assets/images/MenuBackground.png", false, 0, 0, false);

        // Scale background to fit window size
        scaleBackgroundToCover(bg, FlxG.width, FlxG.height);
        bg.updateHitbox(); // Ensures collision/hitbox matches new size
        bg.x = (FlxG.width - bg.width) / 2;
        bg.y = (FlxG.height - bg.height) / 2;

        // Add background to state
        add(bg);

        titleText = new FlxText(25, FlxG.height * 0.25, FlxG.width, "Left: ALIENED");
		titleText.setFormat(null, 32, 0xffffff, "left"); // Set font size, color, and alignment
		add(titleText);

		var playButton:FlxButton;
		playButton = new FlxButton(0, 0, "Play", clickPlay);
		// playButton.screenCenter();

		playButton.x = 25;
		playButton.y = FlxG.height / 2; // Position it vertically in the middle
		add(playButton);

		var optionsButton:FlxButton;
		optionsButton = new FlxButton(playButton.x , playButton.y + playButton.height + padding, "Options", optionsMenu);

		// Align it with the playButton, underneath
		add(optionsButton);

		var rulesButton:FlxButton = new FlxButton(playButton.x, optionsButton.y + optionsButton.height + padding, "How To Play", showRules);
		
		rulesButton.x = playButton.x;
		rulesButton.y = optionsButton.y + optionsButton.height + padding; // Add 10px padding
		add(rulesButton);

		var creditsButton:FlxButton = new FlxButton(playButton.x, rulesButton.y + rulesButton.height + padding, "Credits", showCredits);
		add(creditsButton);

		var closeButton:FlxButton;
		closeButton = new FlxButton(playButton.x , creditsButton.y + creditsButton.height + padding, "Close", closeGame);

		closeButton.x = playButton.x;
		closeButton.y = creditsButton.y + creditsButton.height + padding; // Add 10px padding
		add(closeButton);

		// Rules panel display rules
		// rulesPanel = new FlxSprite(Std.int(FlxG.width * 0.55), Std.int(FlxG.height * 0.2));
		// rulesPanel.makeGraphic(Std.int(FlxG.width * 0.4), Std.int(FlxG.height * 0.6), FlxColor.BLACK);
		// rulesPanel.alpha = 0.5;
		// rulesPanel.visible = false;
		// add(rulesPanel);

		// Credits panel
		creditsPanel = new FlxSprite(FlxG.width - (FlxG.width * 0.4), 0); // Align to right edge
		creditsPanel.makeGraphic(Std.int(FlxG.width * 0.4), FlxG.height, FlxColor.BLACK);
		creditsPanel.alpha = 0.5;
		creditsPanel.visible = false;
		add(creditsPanel);
		creditsText = new FlxText(creditsPanel.x + 10, creditsPanel.y + 10, creditsPanel.width - 20,
		    "LEFT: ALIENED\n" +
		    "\n" +
		    "\n" +
		    "Asteroid-Shooter\n" +
		    "by\n" +
		    "Group 5\n" +
		    "\n" +
		    "\n" +
		    "Lakehead University\n" +
		    "COMP-4478-FA\n" +
		    "Dr. Sabah Mohammed\n" +
		    "\n" +
		    "\n" +
		    "\n" +
		    "\n" +
		    "\n" +
		    "PROGRAMMERS\n" +
		    "\n" +
		    "CORE PROGRAMMERS\n" +
		    "Kego Wigwas\n" +
		    "Hari Vallath\n" +
		    "Desire Ikechi\n" +
		    "\n" +
		    "ADDITIONAL PROGRAMMERS\n" +
		    "Hari Vallath\n" +
		    "Kego Wigwas\n" +
		    "\n" +
		    "UI PROGRAMMERS\n" +
		    "Niraaj Harshadan\n" +
		    "Nihar Poojari\n" +
		    "\n" +
		    "\n" +
		    "\n" +
		    "ART & SOUND DESIGN\n" +
		    "\n" +
		    "ART & SOUND DESIGNER\n" +
		    "Niraaj Harshadan\n" +
		    "\n" +
		    "SPRITES\n" +
		    "LinkNinja via itch.io\n" +
		    "Hari Vallath\n" +
		    "\n" +
		    "MENU BACKGROUND\n" +
		    "NASA/JPL Caltech\n" +
		    "\n" +
		    "LEVEL BACKGROUND\n" +
		    "Screaming Brain Studios via OpenGameArt.org\n" +
		    "\n" +
		    "CONCEPT ARTIST\n" +
		    "Kego Wigwas\n" +
		    "\n" +
		    "MUSIC\n" +
		    "\n" +
		    "Mysteries\n" +
		    "Infrared Scale\n" +
		    "\n" +
		    "The Final Battle\n" +
		    "Infrared Scale\n" +
		    "\n" +
		    "MAZE\n" +
		    "Density & Time\n" +
		    "\n" +
		    "SOUND EFFECTS\n" +
		    "Driken5482 via Pixabay\n" +
		    "freesound_community via Pixabay\n" +
		    "Data_pion via Pixabay\n" +
		    "\n" +
		    "\n" +
		    "\n" +
		    "PROJECT MANAGER\n" +
		    "Hari Vallath\n" +
		    "\n" +
		    "DOCUMENTATION MANAGERS\n" +
		    "Hari Vallath\n" +
		    "Kego Wigwas\n" +
		    "\n" +
		    "\n" +
		    "\n" +
		    "QA ANALYSTS\n" +
		    "Kego Wigwas\n" +
		    "Hari Vallath\n" +
		    "\n" +
		    "\n" +
		    "\n" +
		    "\n" +
		    "\n" +
		    "Press 'Credits' to close panel."
		);

		creditsText.setFormat(null, 12, FlxColor.WHITE, "left");
		creditsText.visible = false;
		add(creditsText);

		rulesText = new FlxText(creditsPanel.x + 10, FlxG.height / 2, creditsPanel.width - 20,
		    "HOW TO PLAY:\n\n" +
		    "1. WASD to move\n" +
		    "2. LMB to shoot\n" +
		    "3. SHIFT/RMB to dodge\n" +
		    "3. SPACE to use SUPER\n" +
		    "4. Hit asteroids/enemies to charge SUPER\n" +
		    "6. Survive the asteroid shower\n" +
		    "7. Survive the enemy drones\n" +
		    "8. Defeat ENEMY LEADERs to gain HP\n" +
		    "4. R to restart\n" +
		    "5. ESC to pause\n" +
		    "\n" +
		    "Press 'How To Play' to close panel."
		);

		rulesText.y = (FlxG.height / 2) - (rulesText.height / 2) - 60;
		rulesText.setFormat(null, 12, FlxColor.WHITE, "left"); // LEFT ALIGNED!!!!
		rulesText.visible = false;
		add(rulesText);
	}

	function closeGame(){
		System.exit(0);
	}

	function clickPlay()
	{
		FlxG.switchState(PlayState.new);
	}


	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		if (bg.width != FlxG.width || bg.height != FlxG.height)
		{
			scaleBackgroundToCover(bg, FlxG.width, FlxG.height);
			bg.x = (FlxG.width - bg.width) / 2;
			bg.y = (FlxG.height - bg.height) / 2;
		}

	    // Scroll credits if active
	    if (creditsActive) {
	        creditsText.y -= creditsScrollSpeed * elapsed;
	        if (creditsText.y + creditsText.height < creditsPanel.y) {
	            // Reset to bottom for continuous loop (optional)
	            creditsText.y = creditsPanel.y + creditsPanel.height;
	        }
	    }
	}

	function showRules():Void
	{
	    rulesText.visible = !rulesText.visible;
	    creditsPanel.visible = rulesText.visible;

		    if (rulesText.visible)
	    {
	        creditsText.visible = false;
	        creditsActive = false;
	    }
	}

	function showCredits():Void
	{
	    creditsText.visible = !creditsText.visible;
	    creditsPanel.visible = creditsText.visible;

	    if (creditsText.visible)
	    {
	        rulesText.visible = false;
	    }

	    if (creditsText.visible) {
	        // Start at bottom of panel
	        creditsText.y = creditsPanel.y + creditsPanel.height;
	        creditsActive = true;
	    } else {
	        creditsActive = false;
	    }
	}
}

class OptionsState extends FlxSubState
{
	public var bg:FlxSprite;
	public var shipPreview:FlxSprite;
	public var shipPreviewBG:FlxSprite;		
	public var shipButton:FlxButton;
	public var currentShipNumber:Int = 0;
	public var volSlider:FlxSlider;

	public static var SHIP_MAX = 6;
	public var padding:Int = 10;

	public function new()
	{
		super();

		bg = new FlxSprite();
        bg.loadGraphic("assets/images/MenuBackground.png", false, 0, 0, false);
        add(bg);

        scaleBackgroundToCover(bg, FlxG.width, FlxG.height);
    }

    // Could be optimized, I just have it copied over from the other class
    function scaleBackgroundToCover(sprite:FlxSprite, targetWidth:Int, targetHeight:Int):Void
    {
        var originalWidth = sprite.graphic.bitmap.width;
        var originalHeight = sprite.graphic.bitmap.height;

        var scaleX:Float = targetWidth / originalWidth;
        var scaleY:Float = targetHeight / originalHeight;

        // Use the larger scale to ensure full coverage (might crop image)
        var scale:Float = Math.max(scaleX, scaleY);

        sprite.scale.set(scale, scale);
        sprite.updateHitbox();
    }
	
	override function create()
	{
		super.create();

		var startX = 25;
		var startY = FlxG.height / 2;

		shipButton = new FlxButton(startX, startY, "", cycleShipChoice);
		add(shipButton);
		updateShipButtonText(); // Set the initial text

		volSlider = new FlxSlider(FlxG.sound, "volume", shipButton.x, shipButton.y + (padding * 2), 0, 1, Std.int(shipButton.width) - 2, 10, 8, FlxColor.WHITE);
		var sliderImg = "assets/images/Slider.png";
		volSlider.handle.loadGraphic(sliderImg);
		volSlider.handle.updateHitbox();

		volSlider.handle.y = volSlider.body.y - (volSlider.handle.height/2) + (volSlider.body.height/2);

		volSlider.setTexts("Volume", false, "0", "100", 6);
		add(volSlider);

		volSlider.x += -5;
		volSlider.minLabel.visible = false;
		volSlider.maxLabel.visible = false;
		volSlider.nameLabel.y = volSlider.handle.y - 10;
		volSlider.nameLabel.setFormat(null, 8, FlxColor.WHITE, "left");

		var backButton:FlxButton;
		backButton = new FlxButton(0, 0 , "Back", backToMenu);
		backButton.x = shipButton.x;
		backButton.y = FlxG.height / 2 + (4 * (shipButton.height + padding)); // Matches close button
		add(backButton);

		shipPreviewBG = new FlxSprite();
		shipPreviewBG.makeGraphic(70, 70, FlxColor.BLACK);
		shipPreviewBG.x = shipButton.x + (shipButton.width / 2) - (shipPreviewBG.width / 2);
		shipPreviewBG.y = shipButton.y - shipPreviewBG.height - padding; // Positioned above
		add(shipPreviewBG);

		shipPreview = new FlxSprite();
		shipPreview.loadGraphic(previewShip(), false, 0, 0);
		shipPreview.scale.set(2, 2);
		shipPreview.updateHitbox(); // Update dimensions after scaling
		// **These lines keep the ship centered inside its background**
		shipPreview.x = shipPreviewBG.x + (shipPreviewBG.width / 2) - (shipPreview.width / 2);
		shipPreview.y = shipPreviewBG.y + (shipPreviewBG.height / 2) - (shipPreview.height / 2);
		add(shipPreview);
	}

		function previewShip():String
		{
			var save = new FlxSave();
			save.bind("LeftAliened");
			var asset:String;
			switch(save.data.shipChoice)
			{
	            case 0: asset = "assets/images/Ship.png";
	            case 1: asset = "assets/images/Ship2.png";
	            case 2: asset = "assets/images/Ship3.png";
	            case 3: asset = "assets/images/Ship4.png";
	            case 4: asset = "assets/images/Ship5.png";
	            case 5: asset = "assets/images/Ship6.png";
	            default: asset = "assets/images/Ship.png";
	        }
	        return asset;
	    }

		function backToMenu()
		{
			close();
		}

		function cycleShipChoice()
		{
			currentShipNumber++;
			if (currentShipNumber >= SHIP_MAX)
			{
				currentShipNumber = 0; // Wrap around to the first ship
			}

			saveShipChoice();
			updateShipButtonText();
			shipPreview.kill();
			shipPreview.loadGraphic(previewShip(),false, 0 ,0 );
			shipPreview.revive();
		}

		function saveShipChoice()
		{
			var save = new FlxSave();
			save.bind("LeftAliened");
			save.data.shipChoice = currentShipNumber;
			save.flush(); // Immediately write the data to the file
			save.close();
		}

		function updateShipButtonText()
		{
			var save = new FlxSave();
			save.bind("LeftAliened");

			var shipName:String = "Missingno";

			switch (save.data.shipChoice) 
			{
				case 0: shipName = "Guardian";
				case 1: shipName = "Odyssey";
				case 2: shipName = "Beyonder";
				case 3: shipName = "Turncoat";
				case 4: shipName = "Developer";
				case 5: shipName = "Thankless";
				default: "Missingno";
			}

			if (save.data.shipChoice != null)
			{
				currentShipNumber = save.data.shipChoice;
				shipButton.text = (currentShipNumber + 1) + ": " + shipName;
				save.close();
			}
			else
			{
			shipButton.text = (currentShipNumber + 1) + ": " + shipName;
			// shipButton.screenCenter(X); // Recenter the button after text changes
			}
		}
}