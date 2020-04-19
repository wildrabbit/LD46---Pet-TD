package org.wildrabbit.pettd;

import flixel.FlxSprite;
import org.wildrabbit.pettd.AssetPaths;
import org.wildrabbit.pettd.Character.CharacterData;


/**
 * ...
 * @author wildrabbit
 */
class Pet extends Character 
{

	public function new(?X:Float=0, ?Y:Float=0, petData:CharacterData) 
	{
		super(X, Y, petData);
	}
	
}