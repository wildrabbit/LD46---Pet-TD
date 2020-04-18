package org.wildrabbit.pettd;

import flixel.FlxSprite;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.system.FlxAssets.FlxTexturePackerSource;
import flixel.graphics.frames.FlxAtlasFrames;

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
	 var sheetFile:FlxGraphicAsset;
	 var atlasFile:FlxTexturePackerSource;
	 var prefix:String;
	 var postfix:String;
	 var anims:Array<AnimData>;
	 var defaultAnim:String;
 }
 
class Character extends FlxSprite 
{
	public function new(?X:Float=0, ?Y:Float=0, data:CharacterData) 
	{
		super(X, Y);
				
		var tex = FlxAtlasFrames.fromTexturePackerJson(data.sheetFile, data.atlasFile);
		frames = tex;
		for (anim in data.anims)
		{
			animation.addByIndices(anim.name, data.prefix, anim.frames, data.postfix, anim.fps);
			
		}
		animation.play(data.defaultAnim);
	}
	
}