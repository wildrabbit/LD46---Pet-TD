package org.wildrabbit.pettd.ui;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.text.FlxText;
import flixel.util.FlxTimer;
import org.wildrabbit.pettd.AssetPaths;

/**
 * ...
 * @author wildrabbit
 */
class MenuState extends FlxState 
{

	override public function create():Void
	{
		super.create();
		FlxG.mouse.visible = false;
		
		bgColor = 0xff9d0b0b;
		
		//var sp:FlxSprite = new FlxSprite(0, 0, "assets/images/main.png");
		//add(sp);
		
		var title:FlxText = new FlxText(FlxG.width / 2 - 240, FlxG.height / 2 - 20, 480, "Pet Protecc TD", 40);
		title.alignment = FlxTextAlign.CENTER;
		title.color = 0xfff6da63;
		add(title);
		
		var sp:FlxSprite = new FlxSprite(FlxG.width / 2 - 16, FlxG.height / 2 - 80);
		var tex = FlxAtlasFrames.fromTexturePackerJson(AssetPaths.pet__png, AssetPaths.pet__json);
		sp.frames = tex;
		sp.animation.addByIndices("blah", "pet", [6,7], ".aseprite", 3);
		sp.animation.play("blah");
		add(sp);
		
		
		var press:FlxText = new FlxText(20, FlxG.height - 20, 300, "Press any key to continue", 10);
		press.color = 0xfff6da63;
		add(press);
		
		var credit:FlxText = new FlxText(FlxG.width - 192, FlxG.height - 20, 192, "LD46 - Ithildin", 10);
		credit.alignment = FlxTextAlign.RIGHT;
		credit.color = 0xfff6da63;
		add(credit);
		//FlxG.sound.playMusic(AssetPaths.music_intro__wav, 0.65, false);
	}
	
	override public function update(dt:Float):Void
	{
		super.update(dt);
		
		if (FlxG.keys.justReleased.ANY)
		{
			FlxG.switchState(new HowToState());
		}
	}
	
}