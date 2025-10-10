package;

import flixel.FlxSprite;
import flixel.FlxG;

class Projectile extends FlxSprite
{
    public static var PLAYER_PROJECTILE_SPEED:Int = 250; // Projectile speed in pixel per sec
    public static var ENEMY_PROJECTILE_SPEED:Int = 95; //125
    public var speed = 1;

    public function new(X:Float, Y:Float, Angle:Float, isEnemy:Bool, assetID: Int = 0)
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
        
        if(isEnemy) 
        {
            speed = ENEMY_PROJECTILE_SPEED;
            this.angle = Angle; //angle already calculated in PlayState
            velocity.x = Math.cos(Angle * (Math.PI / 180)) * E_PROJECTILE_SPEED;
            velocity.y = Math.sin(Angle * (Math.PI / 180)) * E_PROJECTILE_SPEED;
        }
        else 
        {
            speed = PLAYER_PROJECTILE_SPEED;
            this.angle = Angle + 90; // Angle sprite towards where its pointing
        }

        // Set velocity and angle of projectile based on ship
        velocity.x = Math.cos(Angle * (Math.PI / 180)) * speed;
        velocity.y = Math.sin(Angle * (Math.PI / 180)) * speed;
    }

    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);

        if (!isOnScreen())
        {
            kill();
        }
    }
}