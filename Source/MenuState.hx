package;

import flixel.FlxState;
import flixel.ui.FlxButton;
import flixel.FlxG;
import flixel.FlxSprite;


class MenuState extends FlxState
{
	var bg:FlxSprite;

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

		bg = new FlxSprite();
        bg.loadGraphic("assets/images/mbg.jpg", false, 0, 0, false);

        // Scale background to fit window size
        scaleBackgroundToCover(bg, FlxG.width, FlxG.height);
        bg.updateHitbox(); // Ensures collision/hitbox matches new size
        bg.x = (FlxG.width - bg.width) / 2;
        bg.y = (FlxG.height - bg.height) / 2;

        // Add background to state
        add(bg);

	if (FlxG.sound.music == null)
	{
		FlxG.sound.playMusic("assets/music/Menumusic.ogg", 1, true);
	}
		var playButton:FlxButton;
		playButton = new FlxButton(0, 0, "Play", clickPlay);
		add(playButton);
		playButton.screenCenter();
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
