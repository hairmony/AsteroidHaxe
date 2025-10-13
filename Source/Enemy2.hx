import flixel.FlxSprite;
import flixel.FlxG;

class Enemy2 extends FlxSprite {
    public var speed:Float = 50;     //horizontal speed
    public var amp:Float = 10;       //zig-zag amplitude
    public var freq:Float = 1.0;     //zig-zag frequency (waves/sec)
    private var baseY:Float;
    private var time:Float = 0;

    //use nullable params; decide spawn at runtime
    public function new(?X:Null<Float>, ?Y:Null<Float>) {
        var sx = (X != null) ? X : FlxG.width + 32;
        var sy = (Y != null) ? Y : FlxG.random.int(20, FlxG.height - 52);

        super(sx, sy);
        loadGraphic("assets/images/Enemy2.png");

        //force a reasonable on-screen size
        setGraphicSize(32, 32);
        updateHitbox();
        antialiasing = false;
      
        velocity.x = -speed; //moves left
        baseY = sy;
    }

    override public function update(elapsed:Float):Void {
        super.update(elapsed);

        time += elapsed;
        // zig-zag movement
        y = baseY + Math.sin(time * freq * 2 * Math.PI) * amp;

        // remove if off-screen
        if (x + width < -10)
            kill();
    }
}
