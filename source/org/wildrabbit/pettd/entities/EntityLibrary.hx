package org.wildrabbit.pettd.entities;
import org.wildrabbit.pettd.entities.Character;
import org.wildrabbit.pettd.entities.Mob;
import org.wildrabbit.pettd.entities.Character.CharacterData;
import org.wildrabbit.pettd.entities.Mob.MobData;
import org.wildrabbit.pettd.entities.Turret.TurretData;

import openfl.Assets;
import haxe.Json;

/**
 * ...
 * @author wildrabbit
 */
 
class EntityLibrary 
{
	public var defaultPet:CharacterData;
	
	var allPets:Map<Int,CharacterData>;	
	var allMobs:Map<Int,MobData>;
	
	var allTurrets:Map<Int,TurretData>;
	
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
		
		var turretList:Array<TurretData> = data.turrets;
		allTurrets = new Map<Int,TurretData>();
		for (entry in turretList)
		{
			allTurrets.set(entry.id, entry);
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
	
	public function getTurretById(id:Int):TurretData
	{
		if (!allTurrets.exists(id))
		{
			trace('Turret ${id} not found!');
			return null;
		}
		return allTurrets[id];
	}
	
}