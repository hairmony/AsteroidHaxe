package;

import haxe.io.Bytes;
import haxe.io.Path;
import lime.utils.AssetBundle;
import lime.utils.AssetLibrary;
import lime.utils.AssetManifest;
import lime.utils.Assets;

#if sys
import sys.FileSystem;
#end

#if disable_preloader_assets
@:dox(hide) class ManifestResources {
	public static var preloadLibraries:Array<Dynamic>;
	public static var preloadLibraryNames:Array<String>;
	public static var rootPath:String;

	public static function init (config:Dynamic):Void {
		preloadLibraries = new Array ();
		preloadLibraryNames = new Array ();
	}
}
#else
@:access(lime.utils.Assets)


@:keep @:dox(hide) class ManifestResources {


	public static var preloadLibraries:Array<AssetLibrary>;
	public static var preloadLibraryNames:Array<String>;
	public static var rootPath:String;


	public static function init (config:Dynamic):Void {

		preloadLibraries = new Array ();
		preloadLibraryNames = new Array ();

		rootPath = null;

		if (config != null && Reflect.hasField (config, "rootPath")) {

			rootPath = Reflect.field (config, "rootPath");

			if(!StringTools.endsWith (rootPath, "/")) {

				rootPath += "/";

			}

		}

		if (rootPath == null) {

			#if (ios || tvos || webassembly)
			rootPath = "assets/";
			#elseif android
			rootPath = "";
			#elseif (console || sys)
			rootPath = lime.system.System.applicationDirectory;
			#else
			rootPath = "./";
			#end

		}

		#if (openfl && !flash && !display)
		openfl.text.Font.registerFont (__ASSET__OPENFL__flixel_fonts_nokiafc22_ttf);
		openfl.text.Font.registerFont (__ASSET__OPENFL__flixel_fonts_monsterrat_ttf);
		
		#end

		var data, manifest, library, bundle;

		data = '{"name":null,"assets":"aoy4:sizei2397y4:typey5:IMAGEy9:classNamey35:__ASSET__assets_images_asteroid_pngy2:idy30:assets%2Fimages%2FAsteroid.pnggoR0i8970R1R2R3y31:__ASSET__assets_images_boss_pngR5y26:assets%2Fimages%2FBoss.pnggoR0i1741R1R2R3y32:__ASSET__assets_images_enemy_pngR5y27:assets%2Fimages%2FEnemy.pnggoR0i432369R1R2R3y41:__ASSET__assets_images_menubackground_pngR5y36:assets%2Fimages%2FMenuBackground.pnggoR0i349R1R2R3y37:__ASSET__assets_images_projectile_pngR5y32:assets%2Fimages%2FProjectile.pnggoR0i512R1R2R3y38:__ASSET__assets_images_projectile2_pngR5y33:assets%2Fimages%2FProjectile2.pnggoR0i645R1R2R3y38:__ASSET__assets_images_projectile3_pngR5y33:assets%2Fimages%2FProjectile3.pnggoR0i637R1R2R3y38:__ASSET__assets_images_projectile4_pngR5y33:assets%2Fimages%2FProjectile4.pnggoR0i1532R1R2R3y31:__ASSET__assets_images_ship_pngR5y26:assets%2Fimages%2FShip.pnggoR0i1390R1R2R3y32:__ASSET__assets_images_ship2_pngR5y27:assets%2Fimages%2FShip2.pnggoR0i1146R1R2R3y32:__ASSET__assets_images_ship3_pngR5y27:assets%2Fimages%2FShip3.pnggoR0i1742R1R2R3y32:__ASSET__assets_images_ship4_pngR5y27:assets%2Fimages%2FShip4.pnggoR0i315R1R2R3y32:__ASSET__assets_images_ship5_pngR5y27:assets%2Fimages%2FShip5.pnggoR0i2081R1R2R3y32:__ASSET__assets_images_ship6_pngR5y27:assets%2Fimages%2FShip6.pnggoR0i2412115R1y5:MUSICR3y36:__ASSET__assets_music_levelmusic_oggR5y31:assets%2Fmusic%2FLevelMusic.ogggoR0i2892976R1R33R3y35:__ASSET__assets_music_menumusic_oggR5y30:assets%2Fmusic%2FMenuMusic.ogggoR0i8220R1R33R3y31:__ASSET__flixel_sounds_beep_mp3R5y26:flixel%2Fsounds%2Fbeep.mp3goR0i39706R1R33R3y33:__ASSET__flixel_sounds_flixel_mp3R5y28:flixel%2Fsounds%2Fflixel.mp3goR0i15744R1y4:FONTR3y35:__ASSET__flixel_fonts_nokiafc22_ttfR5y30:flixel%2Ffonts%2Fnokiafc22.ttfgoR0i29724R1R42R3y36:__ASSET__flixel_fonts_monsterrat_ttfR5y31:flixel%2Ffonts%2Fmonsterrat.ttfgoR0i222R1R2R3y36:__ASSET__flixel_images_ui_button_pngR5y33:flixel%2Fimages%2Fui%2Fbutton.pnggoR0i484R1R2R3y39:__ASSET__flixel_images_logo_default_pngR5y36:flixel%2Fimages%2Flogo%2Fdefault.pnggoR0i299R1R2R3y45:__ASSET__flixel_images_transitions_circle_pngR5y42:flixel%2Fimages%2Ftransitions%2Fcircle.pnggoR0i730R1R2R3y56:__ASSET__flixel_images_transitions_diagonal_gradient_pngR5y53:flixel%2Fimages%2Ftransitions%2Fdiagonal_gradient.pnggoR0i236R1R2R3y46:__ASSET__flixel_images_transitions_diamond_pngR5y43:flixel%2Fimages%2Ftransitions%2Fdiamond.pnggoR0i209R1R2R3y45:__ASSET__flixel_images_transitions_square_pngR5y42:flixel%2Fimages%2Ftransitions%2Fsquare.pnggh","rootPath":null,"version":2,"libraryArgs":[],"libraryType":null}';
		manifest = AssetManifest.parse (data, rootPath);
		library = AssetLibrary.fromManifest (manifest);
		Assets.registerLibrary ("default", library);
		

		library = Assets.getLibrary ("default");
		if (library != null) preloadLibraries.push (library);
		else preloadLibraryNames.push ("default");
		

	}


}

#if !display
#if flash

@:keep @:bind @:noCompletion #if display private #end class __ASSET__assets_images_asteroid_png extends flash.display.BitmapData { public function new () { super (0, 0, true, 0); } }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__assets_images_boss_png extends flash.display.BitmapData { public function new () { super (0, 0, true, 0); } }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__assets_images_enemy_png extends flash.display.BitmapData { public function new () { super (0, 0, true, 0); } }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__assets_images_menubackground_png extends flash.display.BitmapData { public function new () { super (0, 0, true, 0); } }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__assets_images_projectile_png extends flash.display.BitmapData { public function new () { super (0, 0, true, 0); } }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__assets_images_projectile2_png extends flash.display.BitmapData { public function new () { super (0, 0, true, 0); } }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__assets_images_projectile3_png extends flash.display.BitmapData { public function new () { super (0, 0, true, 0); } }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__assets_images_projectile4_png extends flash.display.BitmapData { public function new () { super (0, 0, true, 0); } }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__assets_images_ship_png extends flash.display.BitmapData { public function new () { super (0, 0, true, 0); } }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__assets_images_ship2_png extends flash.display.BitmapData { public function new () { super (0, 0, true, 0); } }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__assets_images_ship3_png extends flash.display.BitmapData { public function new () { super (0, 0, true, 0); } }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__assets_images_ship4_png extends flash.display.BitmapData { public function new () { super (0, 0, true, 0); } }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__assets_images_ship5_png extends flash.display.BitmapData { public function new () { super (0, 0, true, 0); } }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__assets_images_ship6_png extends flash.display.BitmapData { public function new () { super (0, 0, true, 0); } }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__assets_music_levelmusic_ogg extends flash.utils.ByteArray { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__assets_music_menumusic_ogg extends flash.utils.ByteArray { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__flixel_sounds_beep_mp3 extends flash.media.Sound { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__flixel_sounds_flixel_mp3 extends flash.media.Sound { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__flixel_fonts_nokiafc22_ttf extends flash.text.Font { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__flixel_fonts_monsterrat_ttf extends flash.text.Font { }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__flixel_images_ui_button_png extends flash.display.BitmapData { public function new () { super (0, 0, true, 0); } }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__flixel_images_logo_default_png extends flash.display.BitmapData { public function new () { super (0, 0, true, 0); } }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__flixel_images_transitions_circle_png extends flash.display.BitmapData { public function new () { super (0, 0, true, 0); } }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__flixel_images_transitions_diagonal_gradient_png extends flash.display.BitmapData { public function new () { super (0, 0, true, 0); } }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__flixel_images_transitions_diamond_png extends flash.display.BitmapData { public function new () { super (0, 0, true, 0); } }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__flixel_images_transitions_square_png extends flash.display.BitmapData { public function new () { super (0, 0, true, 0); } }
@:keep @:bind @:noCompletion #if display private #end class __ASSET__manifest_default_json extends flash.utils.ByteArray { }


#elseif (desktop || cpp)

@:keep @:image("Assets/images/Asteroid.png") @:noCompletion #if display private #end class __ASSET__assets_images_asteroid_png extends lime.graphics.Image {}
@:keep @:image("Assets/images/Boss.png") @:noCompletion #if display private #end class __ASSET__assets_images_boss_png extends lime.graphics.Image {}
@:keep @:image("Assets/images/Enemy.png") @:noCompletion #if display private #end class __ASSET__assets_images_enemy_png extends lime.graphics.Image {}
@:keep @:image("Assets/images/MenuBackground.png") @:noCompletion #if display private #end class __ASSET__assets_images_menubackground_png extends lime.graphics.Image {}
@:keep @:image("Assets/images/Projectile.png") @:noCompletion #if display private #end class __ASSET__assets_images_projectile_png extends lime.graphics.Image {}
@:keep @:image("Assets/images/Projectile2.png") @:noCompletion #if display private #end class __ASSET__assets_images_projectile2_png extends lime.graphics.Image {}
@:keep @:image("Assets/images/Projectile3.png") @:noCompletion #if display private #end class __ASSET__assets_images_projectile3_png extends lime.graphics.Image {}
@:keep @:image("Assets/images/Projectile4.png") @:noCompletion #if display private #end class __ASSET__assets_images_projectile4_png extends lime.graphics.Image {}
@:keep @:image("Assets/images/Ship.png") @:noCompletion #if display private #end class __ASSET__assets_images_ship_png extends lime.graphics.Image {}
@:keep @:image("Assets/images/Ship2.png") @:noCompletion #if display private #end class __ASSET__assets_images_ship2_png extends lime.graphics.Image {}
@:keep @:image("Assets/images/Ship3.png") @:noCompletion #if display private #end class __ASSET__assets_images_ship3_png extends lime.graphics.Image {}
@:keep @:image("Assets/images/Ship4.png") @:noCompletion #if display private #end class __ASSET__assets_images_ship4_png extends lime.graphics.Image {}
@:keep @:image("Assets/images/Ship5.png") @:noCompletion #if display private #end class __ASSET__assets_images_ship5_png extends lime.graphics.Image {}
@:keep @:image("Assets/images/Ship6.png") @:noCompletion #if display private #end class __ASSET__assets_images_ship6_png extends lime.graphics.Image {}
@:keep @:file("Assets/music/LevelMusic.ogg") @:noCompletion #if display private #end class __ASSET__assets_music_levelmusic_ogg extends haxe.io.Bytes {}
@:keep @:file("Assets/music/MenuMusic.ogg") @:noCompletion #if display private #end class __ASSET__assets_music_menumusic_ogg extends haxe.io.Bytes {}
@:keep @:file("C:/HaxeToolkit/haxe/lib/flixel/6,1,0/assets/sounds/beep.mp3") @:noCompletion #if display private #end class __ASSET__flixel_sounds_beep_mp3 extends haxe.io.Bytes {}
@:keep @:file("C:/HaxeToolkit/haxe/lib/flixel/6,1,0/assets/sounds/flixel.mp3") @:noCompletion #if display private #end class __ASSET__flixel_sounds_flixel_mp3 extends haxe.io.Bytes {}
@:keep @:font("C:/HaxeToolkit/haxe/lib/flixel/6,1,0/assets/fonts/nokiafc22.ttf") @:noCompletion #if display private #end class __ASSET__flixel_fonts_nokiafc22_ttf extends lime.text.Font {}
@:keep @:font("C:/HaxeToolkit/haxe/lib/flixel/6,1,0/assets/fonts/monsterrat.ttf") @:noCompletion #if display private #end class __ASSET__flixel_fonts_monsterrat_ttf extends lime.text.Font {}
@:keep @:image("C:/HaxeToolkit/haxe/lib/flixel/6,1,0/assets/images/ui/button.png") @:noCompletion #if display private #end class __ASSET__flixel_images_ui_button_png extends lime.graphics.Image {}
@:keep @:image("C:/HaxeToolkit/haxe/lib/flixel/6,1,0/assets/images/logo/default.png") @:noCompletion #if display private #end class __ASSET__flixel_images_logo_default_png extends lime.graphics.Image {}
@:keep @:image("C:/HaxeToolkit/haxe/lib/flixel-addons/3,3,2/assets/images/transitions/circle.png") @:noCompletion #if display private #end class __ASSET__flixel_images_transitions_circle_png extends lime.graphics.Image {}
@:keep @:image("C:/HaxeToolkit/haxe/lib/flixel-addons/3,3,2/assets/images/transitions/diagonal_gradient.png") @:noCompletion #if display private #end class __ASSET__flixel_images_transitions_diagonal_gradient_png extends lime.graphics.Image {}
@:keep @:image("C:/HaxeToolkit/haxe/lib/flixel-addons/3,3,2/assets/images/transitions/diamond.png") @:noCompletion #if display private #end class __ASSET__flixel_images_transitions_diamond_png extends lime.graphics.Image {}
@:keep @:image("C:/HaxeToolkit/haxe/lib/flixel-addons/3,3,2/assets/images/transitions/square.png") @:noCompletion #if display private #end class __ASSET__flixel_images_transitions_square_png extends lime.graphics.Image {}
@:keep @:file("") @:noCompletion #if display private #end class __ASSET__manifest_default_json extends haxe.io.Bytes {}



#else

@:keep @:expose('__ASSET__flixel_fonts_nokiafc22_ttf') @:noCompletion #if display private #end class __ASSET__flixel_fonts_nokiafc22_ttf extends lime.text.Font { public function new () { #if !html5 __fontPath = "flixel/fonts/nokiafc22.ttf"; #else ascender = null; descender = null; height = null; numGlyphs = null; underlinePosition = null; underlineThickness = null; unitsPerEM = null; #end name = "Nokia Cellphone FC Small"; super (); }}
@:keep @:expose('__ASSET__flixel_fonts_monsterrat_ttf') @:noCompletion #if display private #end class __ASSET__flixel_fonts_monsterrat_ttf extends lime.text.Font { public function new () { #if !html5 __fontPath = "flixel/fonts/monsterrat.ttf"; #else ascender = null; descender = null; height = null; numGlyphs = null; underlinePosition = null; underlineThickness = null; unitsPerEM = null; #end name = "Monsterrat"; super (); }}


#end

#if (openfl && !flash)

#if html5
@:keep @:expose('__ASSET__OPENFL__flixel_fonts_nokiafc22_ttf') @:noCompletion #if display private #end class __ASSET__OPENFL__flixel_fonts_nokiafc22_ttf extends openfl.text.Font { public function new () { __fromLimeFont (new __ASSET__flixel_fonts_nokiafc22_ttf ()); super (); }}
@:keep @:expose('__ASSET__OPENFL__flixel_fonts_monsterrat_ttf') @:noCompletion #if display private #end class __ASSET__OPENFL__flixel_fonts_monsterrat_ttf extends openfl.text.Font { public function new () { __fromLimeFont (new __ASSET__flixel_fonts_monsterrat_ttf ()); super (); }}

#else
@:keep @:expose('__ASSET__OPENFL__flixel_fonts_nokiafc22_ttf') @:noCompletion #if display private #end class __ASSET__OPENFL__flixel_fonts_nokiafc22_ttf extends openfl.text.Font { public function new () { __fromLimeFont (new __ASSET__flixel_fonts_nokiafc22_ttf ()); super (); }}
@:keep @:expose('__ASSET__OPENFL__flixel_fonts_monsterrat_ttf') @:noCompletion #if display private #end class __ASSET__OPENFL__flixel_fonts_monsterrat_ttf extends openfl.text.Font { public function new () { __fromLimeFont (new __ASSET__flixel_fonts_monsterrat_ttf ()); super (); }}

#end

#end
#end

#end