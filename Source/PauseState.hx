package;

import flixel.FlxState;
import flixel.FlxObject;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.FlxSubState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxSave;

class PauseState extends FlxSubState
{
	public static var isPaused:Bool = false;

	public function new()
	{
		super(0x33000000);
	}

	override function create()
	{
		super.create();

		isPaused = true;

        // “PAUSED” text
        var pauseText = new FlxText(0, 100, FlxG.width, "PAUSED");
        pauseText.setFormat(null, 32, 0xFFFFFFFF, "center");
        add(pauseText);

        // Continue button
        var btnContinue = new FlxButton(0, 200, "Continue", onContinue);
        btnContinue.screenCenter(X);
        add(btnContinue);

        // Restart button
        var btnRestart = new FlxButton(0, btnContinue.y + 25, "Restart", onRestart);
        btnRestart.screenCenter(X);
        add(btnRestart);

        // Exit button
        var btnExit = new FlxButton(0, btnRestart.y + 25, "Exit", onExit);
        btnExit.screenCenter(X);
        add(btnExit);

	}

	override public function destroy():Void
	{
		super.destroy();

		isPaused = false;
	}

	override public function update(elapsed:Float):Void 
	{
		super.update(elapsed);
		
		// So you can also toggle with Esc key
		if (FlxG.keys.justPressed.ESCAPE)
		{
			onContinue();
		}
	}

	function onContinue():Void
	    {
	    	isPaused = !isPaused;
	    	close();
	    }

    function onRestart():Void
    {
    	isPaused = false;
    	FlxG.resetState();
    }

    function onExit():Void
    {
    	isPaused = false;
    	FlxG.sound.playMusic(null, 1, true);
    	FlxG.switchState(MenuState.new); //Run time bug
    }			

	// Dim background
    // var bg = new FlxSprite();
    // bg.makeGraphic(FlxG.width, FlxG.height, 0x88000000);
    // pauseGroup.add(bg);
}