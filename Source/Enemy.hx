package;
import flixel.FlxState;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.group.FlxGroup;
import flixel.util.FlxSpriteUtil;

class Enemy extends FlxSprite {
	public static var ENEMY_SPEED:Int = 50; //Default value
	var initX:Float;//used to track the inital x coordinate of the enemy

	public function new(assetID:Int = 0){
		super();

		var asset = switch(assetID){
			case 0: "assets/images/EnemyPlaceHolder.png";
			default: "assets/images/EnemyPlaceHolder.png";
		}

		loadGraphic(asset, false);


		initX = FlxG.random.int(0,1) * (FlxG.width - 32);
		x = initX;
		y = FlxG.random.float(0.0,1.0) * (FlxG.height - 32);

		//scale.set(0.1,0.1); //COMMENT OUT IF CORRECT SPRITE IS USED
		updateHitbox();

		//Make enemies travel left or right depending on initial x spawn
		if (x == 0){
			velocity.x = ENEMY_SPEED;
		} else {
			velocity.x = -ENEMY_SPEED;
		}
	}

	override public function update(elapsed:Float):Void {
		super.update(elapsed);
		
		if (!isOnScreen()) {
			y = FlxG.random.float(0.0,1.0) * (FlxG.height - 32);
			x = initX; //reset back to initial x

			//
			if(PlayState.MULTIPLIER > 1){
				PlayState.MULTIPLIER--;
				PlayState.multiplierText.text = PlayState.MULTIPLIER + "X";
				if(PlayState.MULTIPLIER == 1){
					PlayState.multiplierText.visible = false;
				}
			}
		}
	}
}