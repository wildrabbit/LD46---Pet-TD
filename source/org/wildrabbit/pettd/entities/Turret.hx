package org.wildrabbit.pettd.entities;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxNestedSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxVector;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.util.FlxColor;
import flixel.util.FlxSpriteUtil;
import flixel.util.FlxTimer;
import flash.display.BlendMode;
import org.wildrabbit.pettd.entities.Character;
import org.wildrabbit.pettd.entities.Mob;
import org.wildrabbit.pettd.PlayState;

typedef ProjectileData =
{
	var graphic:FlxGraphicAsset;
	var speed: Float;
	var dmg:Int;
	var ttl:Float;
	var ?homing:Bool;
}

typedef SlowingAttackData =
{
	var selfGraphic:FlxGraphicAsset;
	var mobGraphic:FlxGraphicAsset;
	var speedDelta:Int;
	var duration:Float;
}

typedef TurretData = {
	var id:Int;
	var baseGraphic:FlxGraphicAsset;
	var cannonGraphic:FlxGraphicAsset;
	var uiGraphic:FlxGraphicAsset;
	var fireRate:Float;
	var detectionRadius:Float;
	var width:Int;
	var height:Int;
	
	var ?bulletData:ProjectileData;	
	var ?slowData:SlowingAttackData;
	
	var foodCost:Int;
}

/**
 * ...
 * @author wildrabbit
 */
class Turret extends FlxNestedSprite 
{

	//var baseSprite:FlxSprite;
	var cannonSprite:FlxNestedSprite;
	var root:PlayState;
	var mobs:FlxTypedGroup<Mob>;
	var bulletData:ProjectileData;
	
	var freezeData:SlowingAttackData;
	
	var fireRate:Float;
	var detectionRadius:Float;
	
	var currentTarget:Mob;
	
	var fireTimer:FlxTimer;
	var fireReady:Bool;
	var detection:FlxSprite;
	
	var freezeTimer:FlxTimer;
	var freezeReady:Bool;
	
	var turretActive:Bool;
	
	public function new(X:Float=0, Y:Float=0, turretData:TurretData, state:PlayState) 
	{
		super(X, Y);
		loadGraphic(turretData.baseGraphic);
		
		state.levelOverSignal.add(onLevelOver);
		
		
		root = state;
		this.fireRate = turretData.fireRate;
		this.detectionRadius = turretData.detectionRadius;
		
		
		if (turretData.bulletData != null)
		{
			bulletData = turretData.bulletData;			
			
			cannonSprite = new FlxNestedSprite(X,Y);
			add(cannonSprite);
			cannonSprite.x = cannonSprite.y = 0;
			cannonSprite.loadRotatedGraphic(turretData.cannonGraphic, 360);
			cannonSprite.angle = 0;	
			fireTimer = new FlxTimer();
			fireReady = true;
		
		}
		
		if (turretData.slowData != null)
		{
			freezeData = turretData.slowData;
			freezeTimer = new FlxTimer();
			freezeTimer.start(fireRate / 2, function(t:FlxTimer):Void { t.cancel(); freezeReady = true; });
			freezeReady = false;
		}
		
		
		
		detection = new FlxSprite();
		detection.makeGraphic(2 * Math.round(detectionRadius), 2 * Math.round(detectionRadius), FlxColor.TRANSPARENT);
		
		var lineStyle:LineStyle = {
			thickness:1,
			color:FlxColor.fromRGB(255, 255, 255, 128)
		};

		FlxSpriteUtil.drawCircle(detection, detectionRadius, detectionRadius, detectionRadius, FlxColor.TRANSPARENT, lineStyle);
		var center:FlxPoint = getMidpoint().subtract(detectionRadius,detectionRadius);
		
		detection.setPosition(center.x, center.y);
		root.turretVFX.add(detection);
		
		this.mobs = root.mobs;
		
		turretActive = true;
	}
	
	function onLevelOver(result:Result):Void
	{
		turretActive = false;
	}
	
	override public function update(elapsed:Float):Void 
	{
		if (!turretActive) return;
		super.update(elapsed);
		
		if (bulletData != null)
		{
			updateBullet();
		}
		else if (freezeData != null)
		{
			updateFreeze();
		}
		
	}
	
	function updateBullet():Void
	{
		var lastAngle:Float = cannonSprite.relativeAngle;
		var minMobDistance:Float = Math.POSITIVE_INFINITY;
		var targetCandidate:Mob = null;
		var center:FlxPoint = getMidpoint();
		for (mob in mobs)
		{
			var mobDistance = FlxMath.distanceBetween(mob, this);
			if (mobDistance > detectionRadius) continue;
			if (mobDistance < minMobDistance)
			{
				minMobDistance = mobDistance;
				targetCandidate = mob;
			}
		}
		
		if (targetCandidate!= null)
		{
			var targetAngle:Float = center.angleBetween(targetCandidate.getMidpoint());
			cannonSprite.relativeAngle = targetAngle;
		}
		else
		{
			cannonSprite.relativeAngle = lastAngle;
		}
		currentTarget = targetCandidate;
		
		if (canFire())
		{
			fire();
		}
	}
	
	function updateFreeze():Void
	{
		if (canFreeze())
		{
			var targetsInRange:Array<Mob> = new Array<Mob>();
			for (mob in mobs)
			{
				if (FlxMath.distanceBetween(mob, this) <= detectionRadius)
				{
					targetsInRange.push(mob);
				}
			}
			
			if (targetsInRange.length > 0)
			{
				// TODO: Prepare attack vfx
				for (mob in targetsInRange)
				{
					mob.applySlow(freezeData.speedDelta, freezeData.duration, freezeData.mobGraphic);
				}
				freezeReady = false;
				freezeTimer.start(fireRate, onFreezeReady);
			}
				
		}
	}
	
	function onFreezeReady(timer:FlxTimer):Void
	{
		freezeTimer.cancel();
		freezeReady = true;
	}
	
	function canFreeze():Bool
	{
		return freezeReady;
	}
	
	function canFire():Bool
	{
		return currentTarget != null && fireReady;
	}
	
	function fire():Void
	{
		var point:FlxPoint = getMidpoint();
		point.y -= height / 2;
		point.rotate(getMidpoint(), cannonSprite.relativeAngle);
		// spawn projectile
		root.shootBullet(point, currentTarget, bulletData);
		fireReady = false;
		fireTimer.start(fireRate, onTimerSet);
	}
	
	function onTimerSet(timer:FlxTimer):Void
	{
		fireTimer.cancel();
		fireReady = true;
	}
}