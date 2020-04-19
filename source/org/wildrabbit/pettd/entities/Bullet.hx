package org.wildrabbit.pettd.entities;

import flash.utils.Timer;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.math.FlxVector;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.util.FlxSignal.FlxTypedSignal;
import flixel.util.FlxTimer;
import org.wildrabbit.pettd.entities.Character;
import org.wildrabbit.pettd.entities.Turret.ProjectileData;

/**
 * ...
 * @author wildrabbit
 */
class Bullet extends FlxSprite 
{
	public var dmg:Int;
	var speed:Float;
	var homing:Bool = false;
	var target:Character;
	var timer:FlxTimer;
	
	public var destroyed:FlxTypedSignal<Bullet->Void>;
	
	public function new(?X:Float=0, ?Y:Float=0, bulletData:ProjectileData, target:Character) 
	{
		super(X, Y, bulletData.graphic);
		dmg = bulletData.dmg;
		speed = bulletData.speed;
		homing = bulletData.homing != null && bulletData.homing;
		SetTarget(target);
		target.died.add(targetDied);
		
		timer = new FlxTimer();
		timer.start(bulletData.ttl, onExpired);
		
		destroyed = new FlxTypedSignal<Bullet->Void>();
	}
	
	public function SetTarget(tgt:Character):Void
	{
		target = tgt;
		var targetPos:FlxPoint = target.getMidpoint();
		var pos:FlxPoint = FlxPoint.get(x, y);
		var vel:FlxVector = FlxVector.get(targetPos.x - pos.x, targetPos.y - pos.y);
		vel.normalize();
		vel.scale(speed);
		velocity.set(vel.x, vel.y);
		pos.put();
	}
	
	override public function update(elapsed:Float):Void 
	{
		super.update(elapsed);
		if (homing)
		{
			SetTarget(target);
		}
	}
	
	function targetDied(tgt:Character):Void
	{
		//killBullet();
	}
	
	function onExpired(timer:FlxTimer):Void
	{
		onKillExpired(timer);
	}
	
	public function onHit():Void
	{
		trace("Boom!");
		killBullet();
	}
	
	function killBullet():Void
	{
		timer.cancel();
		allowCollisions = FlxObject.NONE;
		timer.start(0.1, onKillExpired);
	}
	
	function onKillExpired(timer:FlxTimer):Void
	{
		timer.cancel();
		kill();
		destroyed.dispatch(this);		
	}
}