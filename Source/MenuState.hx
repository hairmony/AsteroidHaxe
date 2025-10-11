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



class MenuState extends FlxState
{
	var bg:FlxSprite;
	var titleText:FlxText; // Variable for the title

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

		FlxG.sound.playMusic("assets/music/MenuMusic.ogg", 1, true);

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
		optionsButton = new FlxButton(playButton.x , playButton.y + 25, "Options", optionsMenu);

		// Align it with the playButton, underneath
		optionsButton.x = playButton.x;
		optionsButton.y = playButton.y + playButton.height + 10; // Add 10px padding
		add(optionsButton);

		var closeButton:FlxButton;
		closeButton = new FlxButton(optionsButton.x , optionsButton.y + 25, "Exit", closeGame);

		closeButton.x = optionsButton.x;
		closeButton.y = optionsButton.y + optionsButton.height + 10; // Add 10px padding
		add(closeButton);

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
	}
}

class OptionsState extends FlxSubState
{
	public var bg:FlxSprite;
	public var shipPreview:FlxSprite;
	public var shipPreviewBG:FlxSprite;		
	public var shipButton:FlxButton;
	public var currentShipNumber:Int = 0;

	public static var SHIP_MAX = 3;

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

		final padding:Float = 10;
		final startX:Float = 25;
		final startY:Float = FlxG.height / 2;

		shipButton = new FlxButton(startX, startY, "", cycleShipChoice);
		add(shipButton);
		updateShipButtonText(); // Set the initial text

		var backButton:FlxButton;
		backButton = new FlxButton(0, 0 , "Back", backToMenu);
		backButton.x = shipButton.x;
		backButton.y = shipButton.y + shipButton.height + padding;
		add(backButton);

		shipPreviewBG = new FlxSprite();
		shipPreviewBG.makeGraphic(70, 70, FlxColor.WHITE);
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
			shipButton.screenCenter(X); // Recenter the button after text changes
			}
		}
}