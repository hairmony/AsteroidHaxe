package;

import flixel.FlxState;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.util.FlxSpriteUtil;
import flixel.input.keyboard.FlxKey;
import flixel.util.FlxTimer;

class Player extends FlxSprite {
	//var sprite:FlxSprite;
	public static var PLAYER_SPEED = 150; //150

	// Dodging variables
	public var isDodging:Bool = false;
	public var dodgeDuration:Float = 0.25; // Seconds
	public static var DODGE_SPEED:Float = 400; // Speed DURIGN dod40
	public var dodgeTimer:Float = 0;

	public var isInvincible = false;

	public var asset:String = "assets/images/Ship.png";

	public function new(assetID: Int = 0)
	{
		super((FlxG.width/2),(FlxG.height/2));
		//sprite = new FlxSprite();

		asset = switch(assetID) {
            case 0: "assets/images/Ship.png";
            case 1: "assets/images/Ship2.png";
            case 2: "assets/images/Ship3.png";
            case 3: "assets/images/Ship4.png";
            case 4: "assets/images/Ship5.png";
            case 5: "assets/images/Ship6.png";
            default: "assets/images/Ship.png";
        };

		loadGraphic(asset);//Dimensions for placeholder
			
		x = (FlxG.width/2) - (width/2); 
		y = (FlxG.height /2) - (height /2);

		scale.set(1.1, 1.1); // Sprite scale. COMMENT OUT IF SPRITE IS OF CORRECT SIZE
		updateHitbox();
	}
	
	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);

		if(FlxG.keys.enabled){
			if(FlxG.keys.pressed.A){
				x -= PLAYER_SPEED * elapsed;
			}
			if(FlxG.keys.pressed.D){
				x += PLAYER_SPEED * elapsed;
			}
			if(FlxG.keys.pressed.W){
				y -= PLAYER_SPEED * elapsed;
			}
			if(FlxG.keys.pressed.S){
				y += PLAYER_SPEED * elapsed;
			}
		}

		if (FlxG.mouse.enabled){
			var center_x:Float = x + (width / 2);
			var center_y:Float = y + (height / 2);

			var dx:Float = FlxG.mouse.x - center_x;
			var dy:Float = FlxG.mouse.y - center_y;

			var angRad:Float = Math.atan2(dy, dx);

			var angDeg:Float = angRad * (180 / Math.PI);

			angle = angDeg + 90;
		}

		if (isDodging)
		{
		    dodgeTimer += FlxG.elapsed;

		    // Dodge trail!
		    var trail = new FlxSprite(x, y);
		    trail.loadGraphic(this.asset);
		    trail.alpha = 0.2;
		    trail.angle = angle;
		    FlxG.state.add(trail);
		    // Kill trail
		    new FlxTimer().start(0.2, function(t:FlxTimer){ trail.kill(); });

		    // Move forward in the direction ship facing currently
		    var angleRad = (angle - 90) * Math.PI / 180;
		    x += Math.cos(angleRad) * DODGE_SPEED * FlxG.elapsed;
		    y += Math.sin(angleRad) * DODGE_SPEED * FlxG.elapsed;

		    // Dodge ending
		    if (dodgeTimer >= dodgeDuration)
		    {
		        isDodging = false;
		        isInvincible = false;
		    }
		}
	}
}