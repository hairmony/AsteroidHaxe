package;

import flixel.FlxState;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.util.FlxSpriteUtil;
import flixel.input.keyboard.FlxKey;

class Player extends FlxSprite {
	//var sprite:FlxSprite;
	public static var PLAYER_SPEED = 150;

	public function new(assetID: Int = 0){
		super((FlxG.width/2),(FlxG.height/2));
		//sprite = new FlxSprite();

		var asset = switch(assetID) {
            case 0: "assets/images/Ship.png";
            case 1: "assets/images/Ship2.png";
            case 2: "assets/images/Ship3.png";
            case 3: "assets/images/Ship4.png";
            default: "assets/images/Ship.png";
        };

		loadGraphic(asset);//Dimensions for placeholder
			
		x = (FlxG.width/2) - (width/2); 
		y = (FlxG.height /2) - (height /2);

		scale.set(1.1, 1.1); // Sprite scale. COMMENT OUT IF SPRITE IS OF CORRECT SIZE
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
	}
}