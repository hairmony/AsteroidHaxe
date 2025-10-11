package;

import flixel.FlxSprite;
import flixel.FlxG;

class Projectile extends FlxSprite
{
    public static var PLAYER_PROJECTILE_SPEED:Int = 255; // Projectile speed in pixel per sec
    public static var ENEMY_PROJECTILE_SPEED:Int = 125; //95
    public static var BOSS_PROJECTILE_SPEED:Int = 100;

    public var speed = 1;
    public var isEnemy:Int = 0;

    public function new(X:Float, Y:Float, Angle:Float, isEnemy:Int = 0, assetID: Int = 0)
    {
        super(X, Y);

        var asset = switch(assetID) {
            case 0: "assets/images/Projectile.png";
            case 1: "assets/images/Projectile2.png";
            case 2: "assets/images/Projectile3.png";
            case 3: "assets/images/Projectile4.png";
            default: "assets/images/Projectile.png";
        };

        loadGraphic(asset, false);
        
        x -= width / 2;
        y -= height / 2;
        
        if(isEnemy == 1) 
        {
            speed = ENEMY_PROJECTILE_SPEED;
            this.angle = Angle; //angle already calculated in PlayState
        }
        else if (isEnemy == 2)
        {
            speed = BOSS_PROJECTILE_SPEED;
            this.angle = Angle + 90;
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