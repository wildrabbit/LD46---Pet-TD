package org.wildrabbit.pettd.ui;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;

/**
 * ...
 * @author wildrabbit
 */
class GameWonState extends FlxState 
{
	override public function create():Void
	{
		super.create();
		FlxG.mouse.visible = false;
		
		bgColor = 0xff9d0b0b;
		
		//var sp:FlxSprite = new FlxSprite(0, 0, "assets/images/gover.png");
		//add(sp);
		var text:FlxText = new FlxText(FlxG.width / 2 - 300, FlxG.height / 2 - 40, 600, "Congrats!", 40);
		
		text.alignment = FlxTextAlign.CENTER;
		text.color = 0xffeb8242;
		add(text);
	}
	
	override public function update(dt:Float):Void
	{
		super.update(dt);
		
		if (FlxG.keys.justReleased.ANY)
		{
			FlxG.switchState(new PlayState());
		}
	}
}