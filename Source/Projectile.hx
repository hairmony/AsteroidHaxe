package;

import flixel.FlxSprite;
import flixel.FlxG;

class Projectile extends FlxSprite
{
    public static var PROJECTILE_SPEED:Int = 300; // Projectile speed in pixel per sec

    public function new(X:Float, Y:Float, Angle:Float)
    {
        super(X, Y);
        loadGraphic("assets/images/Projectile.png");

        // Set velocity and angle of projectile based on ship
        velocity.x = Math.cos(Angle * (Math.PI / 180)) * PROJECTILE_SPEED;
        velocity.y = Math.sin(Angle * (Math.PI / 180)) * PROJECTILE_SPEED;
    }

    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);

		// Kill if projectile goes off-screen
        if (!isOnScreen())
        {
            kill();
        }
    }
}
