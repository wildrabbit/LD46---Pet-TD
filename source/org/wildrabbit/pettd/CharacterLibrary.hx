package org.wildrabbit.pettd;
import org.wildrabbit.pettd.Character.CharacterData;
import org.wildrabbit.pettd.Mob.MobData;

import openfl.Assets;
import haxe.Json;

/**
 * ...
 * @author wildrabbit
 */
 
class CharacterLibrary 
{
	public var defaultPet:CharacterData;
	
	var allPets:Map<Int,CharacterData>;	
	var allMobs:Map<Int,MobData>;
	
	public function new(jsonPath:String) 
	{
		var libraryFile:String = Assets.getText(jsonPath);
		var data = Json.parse(libraryFile);
		
		var mobList:Array<MobData> = data.mobs;
		allMobs = new Map<Int,MobData>();
		for (entry in mobList)
		{
			allMobs.set(entry.characterData.id, entry);
		}
		
		var defaultPetIdx:Int = data.defaultPet;

		var petList:Array<CharacterData> = data.pets;
		allPets = new Map<Int,CharacterData>();
		for (entry in petList)
		{
			allPets.set(entry.id, entry);
			if (entry.id == defaultPetIdx)
			{
				defaultPet = entry;
			}
		}
	}
	
	public function getMobById(id:Int):MobData
	{
		if (!allMobs.exists(id))
		{
			trace('Mob ${id} not found!');
			return null;
		}
		return allMobs[id];
	}
	
}