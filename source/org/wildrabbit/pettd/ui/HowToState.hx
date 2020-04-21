package org.wildrabbit.pettd.ui;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.text.FlxText;
import org.wildrabbit.pettd.AssetPaths;

/**
 * ...
 * @author wildrabbit
 */
class HowToState extends FlxState 
{
	override public function create():Void
	{
		super.create();
		FlxG.mouse.visible = false;
		
		//var sp:FlxSprite = new FlxSprite(0, 0, AssetPaths.howto__png);
		//add(sp);
		
		var title:FlxText = new FlxText(FlxG.width / 2 - 200, 20, 400, "How to Play", 32);
		title.alignment = FlxTextAlign.CENTER;
		title.color = 0xffeb8242;
		add(title);
		
		var sp:FlxSprite = new FlxSprite(FlxG.width / 2 - 16, 64);
		var tex = FlxAtlasFrames.fromTexturePackerJson(AssetPaths.pet__png, AssetPaths.pet__json);
		sp.frames = tex;
		sp.animation.addByIndices("blah", "pet", [0,1], ".aseprite", 3);
		sp.animation.play("blah");
		add(sp);
		
		var proteccDesc:FlxText = new FlxText(24, 100, 744, "Take care of this little chap above.\nTap on the critter in the map or press the FEED button to give it some fruit.\n Keep it well fed and it'll heal. Starve it and it will take damage!", 14);
		proteccDesc.color = 0xfff6da63;
		add(proteccDesc);
		
		var mob2:FlxSprite = new FlxSprite(FlxG.width / 2 - 20, 192);
		tex = FlxAtlasFrames.fromTexturePackerJson(AssetPaths.mob2__png, AssetPaths.mob2__json);
		mob2.frames = tex;
		mob2.animation.addByIndices("blah", "mob2", [0], ".aseprite", 1);
		mob2.animation.play("blah");
		add(mob2);
		
		var mob3:FlxSprite = new FlxSprite(FlxG.width / 2 + 16, 192);
		tex = FlxAtlasFrames.fromTexturePackerJson(AssetPaths.mob3__png, AssetPaths.mob3__json);
		mob3.frames = tex;
		mob3.animation.addByIndices("blah", "mob3", [0], ".aseprite", 1);
		mob3.animation.play("blah");
		add(mob3);
		
		
		var turretDesc:FlxText = new FlxText(24, 230, 744, "Fruit drops from mobs like these, which will come in waves trying to attack it.\n", 14);
		turretDesc.color = 0xfff6da63;
		add(turretDesc);
		
		var turretBuyDesc:FlxText = new FlxText(24, 244, 744, "Tap on the turret icons in the bar to purchase them (they cost fruit, too!) and then in the map to place them.", 14);
		turretBuyDesc.color = 0xfff6da63;
		add(turretBuyDesc);
		
		var t1:FlxSprite = new FlxSprite(FlxG.width / 2 - 36, 272, AssetPaths.turret1_ui__png);
		add(t1);
		var t2:FlxSprite = new FlxSprite(FlxG.width / 2 + 32, 272, AssetPaths.turret2_ui__png);
		add(t2);
		
		var othersTitle:FlxText = new FlxText(FlxG.width / 2 - 200, 340, 400, "Other controls", 24);
		othersTitle.alignment = FlxTextAlign.CENTER;
		othersTitle.color = 0xffeb8242;
		add(othersTitle);
		
		var others:FlxText = new FlxText(24, 370, 744, "* ESC: reset game.\n* R: Restart current level\n* F1: Toggle turrets' range display on/off", 14);
		others.color = 0xfff6da63;
		add(others);
		
		var press:FlxText = new FlxText(20, FlxG.height - 20, 256, "Press any key to continue", 10);
		press.color = 0xfff6da63;
		add(press);
		
		//FlxG.sound.playMusic(AssetPaths.music_howto__wav, 0.8);
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