package;

import flixel.FlxState;
import flixel.ui.FlxButton;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.util.FlxSave;


class MenuState extends FlxState
{
	var bg:FlxSprite;
	var titleText:FlxText; // Variable for the title

	public var shipButton:FlxButton;
	public var currentShipNumber:Int = 0;
	public static var SHIP_MAX = 3;

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

        titleText = new FlxText(25, FlxG.height * 0.25, FlxG.width, "Left: ALIGNED");
		titleText.setFormat(null, 32, 0xffffff, "left"); // Set font size, color, and alignment
		add(titleText);

		var playButton:FlxButton;
		playButton = new FlxButton(0, 0, "Play", clickPlay);
		add(playButton);
		playButton.screenCenter();

		shipButton = new FlxButton(0, playButton.y + 25, "", cycleShipChoice);
		add(shipButton);
		updateShipButtonText(); // Set the initial text
	}

	function clickPlay()
	{
		FlxG.switchState(PlayState.new);
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
	}

	function saveShipChoice()
	{
		var save = new FlxSave();
		save.bind("LeftAligned");
		save.data.shipChoice = currentShipNumber;
		save.flush(); // Immediately write the data to the file
		save.close();
	}

	function updateShipButtonText()
	{
		// We add 1 to the index to show "Ship: 1" instead of "Ship: 0"
		shipButton.text = "Ship: " + (currentShipNumber + 1);
		shipButton.screenCenter(X); // Recenter the button after text changes
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