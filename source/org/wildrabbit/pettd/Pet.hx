package org.wildrabbit.pettd;

import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.system.FlxAssets.FlxGraphicAsset;
import org.wildrabbit.pettd.AssetPaths;

/**
 * ...
 * @author wildrabbit
 */
class Pet extends FlxSprite 
{

	public function new(?X:Float=0, ?Y:Float=0) 
	{
		super(X, Y);
		
		var tex = FlxAtlasFrames.fromTexturePackerJson(AssetPaths.proto_pet__png, AssetPaths.proto_pet__json);
		frames = tex;
		animation.addByIndices("idle", "proto-pet", [0, 1], ".aseprite", 4);
		animation.play("idle");
	}
	
}