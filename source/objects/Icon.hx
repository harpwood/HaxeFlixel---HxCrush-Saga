package objects;

import flixel.FlxSprite;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.tweens.FlxTween;

class Icon extends FlxSprite
{
	public var name(default, default):String;
	public var skin(default, default):String;
	public var tween(default, default):FlxTween;

	private var isGivingHint:Bool = false;

	public function new(?X:Float = 0, ?Y:Float = 0, ?SimpleGraphic:FlxGraphicAsset)
	{
		super(X, Y, SimpleGraphic);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
	}

	public function giveHint(value:Bool):Void
	{
		isGivingHint = value;
	}

	public function destroyMe():Void
	{
		if (tween != null)
			tween.cancel;
		name = "destroyed";
		destroy();
	}
}
