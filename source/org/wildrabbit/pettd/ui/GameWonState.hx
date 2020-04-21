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
		var text:FlxText = new FlxText(FlxG.width / 2 - 300, FlxG.height / 2 - 90, 600, "You beat the game!", 40);
		
		text.alignment = FlxTextAlign.CENTER;
		text.color = 0xffeb8242;
		add(text);
		
		var text2:FlxText = new FlxText(FlxG.width / 2 - 300, FlxG.height / 2 - 40, 600, "Thanks for playing :D", 24);	
		text2.alignment = FlxTextAlign.CENTER;
		text2.color = 0xfff6da63;
		add(text2);
		
		var press:FlxText = new FlxText(20, FlxG.height - 20, 256, "Press any key to continue", 10);
		press.color = 0xfff6da63;
		add(press);
	}
	
	override public function update(dt:Float):Void
	{
		super.update(dt);
		
		if (FlxG.keys.justReleased.ANY || FlxG.mouse.justPressed)
		{
			FlxG.sound.play(AssetPaths.tap_menu__wav);
			FlxG.switchState(new MenuState());
		}
	}
}