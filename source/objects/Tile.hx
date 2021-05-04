package objects;

import flixel.FlxSprite;
import flixel.system.FlxAssets.FlxGraphicAsset;

class Tile extends FlxSprite
{
	public var row(default, default):Int;
	public var col(default, default):Int;

	public function new(?X:Float = 0, ?Y:Float = 0, ?SimpleGraphic:FlxGraphicAsset)
	{
		super(X, Y, SimpleGraphic);

		loadGraphic("assets/images/tile.png", false, 60, 60);
	}
}
