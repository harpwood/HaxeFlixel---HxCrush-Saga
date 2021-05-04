package objects;

import flixel.FlxSprite;
import flixel.system.FlxAssets.FlxGraphicAsset;

class Frame extends FlxSprite
{
	public function new(?X:Float = 0, ?Y:Float = 0, ?SimpleGraphic:FlxGraphicAsset)
	{
		super(X, Y, SimpleGraphic);
		loadGraphic("assets/images/frame.png", true, 60, 60);
		animation.add("frame", [0, 1, 2, 3, 4, 4, 3, 2, 1, 0], 15, true);
		animation.play("frame", true);
	}
}
