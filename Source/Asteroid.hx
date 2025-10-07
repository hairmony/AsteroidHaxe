package;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.util.FlxSpriteUtil;

class Asteroid extends FlxSprite {
	public function new(){
		super();
		loadGraphic("assets/images/Asteroid.png");

		x = (FlxG.width/2); 
		y = (FlxG.height/2);
		//Making the x and y coordinates not the center of the screen extends the hitbox past the sprite boundaries by offset
		
		// scale.set(0.2,0.2); //Scale not needed if actual sprite is correct size
		updateHitbox(); //Only use after scale is set
	}

	override public function update(elapsed:Float):Void {
		//Asteroid behaviour goes here
		//Update the sprite.velocity.x and sprite.velocity.x
	}
}