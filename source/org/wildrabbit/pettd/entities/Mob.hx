package org.wildrabbit.pettd.entities;

import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.tile.FlxBaseTilemap.FlxTilemapDiagonalPolicy;
import flixel.util.FlxPath;
import flixel.util.FlxSignal;
import org.wildrabbit.pettd.AssetPaths;
import org.wildrabbit.pettd.entities.Character;
import org.wildrabbit.pettd.world.Level;

typedef MobData =
{
	var characterData:CharacterData;
	var damage:Int;
	var speed:Int;
	// TODO: Change to weighted list + types
	var nutrientSpawnChance:Float;
	var nutrientSpawnMin:Int;
	var nutrientSpawnMax:Int;
	var nutrientType:String;
}

/**
 * ...
 * @author wildrabbit
 */
class Mob extends Character 
{
	static  var maxID:Int = 0;
	var moving:Bool = false;
	public var damage:Int;
	public var speed:Int;
	
	public var spawnChance:Float;
	public var spawnMin:Int;
	public var spawnMax:Int;
	public var spawnType:String;
	
	public var mobUID:Int;
	
	public function new(?X:Float=0, ?Y:Float=0, mobData:MobData) 
	{
		super(X, Y, mobData.characterData);
		
		damage = mobData.damage;
		speed = mobData.speed;
		
		path = new FlxPath();
		moving = false;
		path.cancel();
		velocity.x = velocity.y = 0;
		
		spawnChance = mobData.nutrientSpawnChance;
		spawnMin = mobData.nutrientSpawnMin;
		spawnMax = mobData.nutrientSpawnMax;
		spawnType = mobData.nutrientType;
		
		mobUID = Mob.maxID++;
	}
	
	public function goTo(target:FlxSprite, level:Level):Void
	{
		var start:FlxPoint = getMidpoint();
		var end:FlxPoint = target.getMidpoint();
		var pathPoints:Array<FlxPoint> = level.navigationMap.findPath(start, end, true, false, FlxTilemapDiagonalPolicy.NONE);
		path.start(pathPoints,speed, FlxPath.FORWARD);
		
		moving = true;
	}
	
	override public function update(elapsed:Float):Void 
	{
		super.update(elapsed);
		
		if (moving && path.finished)
		{
			path.cancel();
			velocity.x = velocity.y = 0;
			moving = false;
		}
	}
	
	public function petHit():Void
	{
		takeDamage(hp);
	}
	
	public function stop():Void
	{
		if (moving)
		{
			path.cancel();
			velocity.x = velocity.y = 0;
			moving = false;
		}
	}
	
		
	public override function takeDamage(dmg:Int):Void
	{
		var startHP:Int = hp;
		super.takeDamage(dmg);		
		trace('Mob ${mobUID} took ${startHP - hp} dmg');
	}
}