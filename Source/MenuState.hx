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

		FlxG.sound.playMusic("assets/music/Menumusic.ogg", 1, true);

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
		add(playButton);
		playButton.screenCenter();

		var optionsButton:FlxButton;
		optionsButton = new FlxButton(playButton.x , playButton.y + 25, "Options", optionsMenu);
		add(optionsButton);

		var closeButton:FlxButton;
		closeButton = new FlxButton(optionsButton.x , optionsButton.y + 25, "Exit", closeGame);
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
    }
	
	override function create()
	{
		super.create();

		shipButton = new FlxButton(0, 0 , "", cycleShipChoice);
		add(shipButton);
		shipButton.screenCenter();
		updateShipButtonText(); // Set the initial text

		var backButton:FlxButton;
		backButton = new FlxButton(0, shipButton.y + 25 , "Back", backToMenu);
		backButton.screenCenter(X);
		add(backButton);

		shipPreviewBG = new FlxSprite();
		shipPreviewBG.makeGraphic(70,70, FlxColor.WHITE);
		shipPreviewBG.screenCenter(X);
		shipPreviewBG.y=shipButton.y - 95;
		add(shipPreviewBG);

		shipPreview = new FlxSprite();
		shipPreview.loadGraphic(previewShip(),false, 0 ,0 );
		shipPreview.scale.set(2,2);
		shipPreview.screenCenter(X);
		shipPreview.y=shipButton.y - 75;
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
			if (save.data.shipChoice != null)
			{
				currentShipNumber = save.data.shipChoice;
				shipButton.text = "Ship: " + (currentShipNumber + 1);
				save.close();
			}
			else
			{
			shipButton.text = "Ship: " + (currentShipNumber + 1);
			shipButton.screenCenter(X); // Recenter the button after text changes
			}
		}
}