package org.wildrabbit.pettd.entities;

import flixel.FlxSprite;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.system.FlxAssets.FlxTexturePackerSource;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.util.FlxSignal.FlxTypedSignal;

/**
 * ...
 * @author wildrabbit
 */

 typedef AnimData =
 {
	 var name:String;
	 var frames:Array<Int>;
	 var fps:Int;
 }

 typedef CharacterData =
 {
	 var id:Int;
	 var name:String;
	 var sheetFile:FlxGraphicAsset;
	 var atlasFile:FlxTexturePackerSource;
	 var prefix:String;
	 var postfix:String;
	 var anims:Array<AnimData>;
	 var defaultAnim:String;
	 var maxHP: Int;
 }
 
class Character extends FlxSprite 
{
	public var hp:Int;
	public var maxHP:Int;
	
		
	public var damaged:FlxTypedSignal<Character-> Int-> Void>;
	public var died:FlxTypedSignal<Character-> Void>;
	
	public function new(?X:Float=0, ?Y:Float=0, data:CharacterData) 
	{
		super(X, Y);
		
		maxHP = hp = data.maxHP;
				
		var tex = FlxAtlasFrames.fromTexturePackerJson(data.sheetFile, data.atlasFile);
		frames = tex;
		for (anim in data.anims)
		{
			animation.addByIndices(anim.name, data.prefix, anim.frames, data.postfix, anim.fps);
			
		}
		animation.play(data.defaultAnim);
		
		damaged = new FlxTypedSignal<Character->Int->Void>();
		died= new FlxTypedSignal<Character->Void>();
	}
	
	public function takeDamage(dmg:Int):Void
	{
		var effectiveDamage:Int = hp < dmg ? hp : dmg;
		hp -= effectiveDamage;

		damaged.dispatch(this, effectiveDamage);
		if (hp == 0)
		{
			kill();
			died.dispatch(this);
		}
	}
	
}