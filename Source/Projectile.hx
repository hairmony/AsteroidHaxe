package;

import flixel.FlxSprite;
import flixel.FlxG;

class Projectile extends FlxSprite
{
    public static var PROJECTILE_SPEED:Int = 300; // Projectile speed in pixel per sec

    public function new(X:Float, Y:Float, Angle:Float, assetID: Int = 0)
    {
        super(X, Y);

        var asset = switch(assetID) {
            case 0: "assets/images/Projectile.png";
            case 1: "assets/images/Projectile2.png";
            case 2: "assets/images/Projectile3.png";
            default: "assets/images/Projectile.png";
        };

        loadGraphic(asset, false);
        x -= width / 2;
        y -= height / 2;
        
        this.angle = Angle + 90; // Angle sprite towards where its pointing

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

