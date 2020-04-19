package org.wildrabbit.pettd;

import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.tile.FlxBaseTilemap.FlxTilemapDiagonalPolicy;
import flixel.util.FlxPath;
import flixel.util.FlxSignal;
import org.wildrabbit.pettd.AssetPaths;
import org.wildrabbit.pettd.Character;
import org.wildrabbit.pettd.world.Level;

typedef MobData =
{
	var characterData:CharacterData;
	var damage:Int;
	var speed:Int;
}

/**
 * ...
 * @author wildrabbit
 */
class Mob extends Character 
{
	var moving:Bool = false;
	public var damage:Int;
	public var speed:Int;
	
	public function new(?X:Float=0, ?Y:Float=0, mobData:MobData) 
	{
		super(X, Y, mobData.characterData);
		
		damage = mobData.damage;
		speed = mobData.speed;
		
		path = new FlxPath();
		moving = false;
		path.cancel();
		velocity.x = velocity.y = 0;
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
}