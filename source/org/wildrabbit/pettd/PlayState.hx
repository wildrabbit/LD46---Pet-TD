package org.wildrabbit.pettd;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.input.keyboard.FlxKey;
import flixel.math.FlxPoint;
import flixel.math.FlxRandom;
import flixel.system.debug.log.LogStyle;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxSignal;
import flixel.util.FlxTimer;
import haxe.macro.Expr.Var;
import org.wildrabbit.pettd.entities.Bullet;
import org.wildrabbit.pettd.entities.EntityLibrary;
import org.wildrabbit.pettd.entities.Character;
import org.wildrabbit.pettd.entities.Mob;
import org.wildrabbit.pettd.entities.Pet;
import org.wildrabbit.pettd.entities.Pickable;
import org.wildrabbit.pettd.entities.Turret;
import org.wildrabbit.pettd.ui.HUDBar;
import org.wildrabbit.pettd.world.Level;
import org.wildrabbit.pettd.world.LevelDataTable;


import flixel.FlxState;

enum Result {
	Running;
	Won;
	Lost;
}

class PlayState extends FlxState
{
	// TODO: Check what groups we need here.
	
	var gameGroup:FlxGroup;
	
	public var pet:Pet; // Pet.
	public var turrets:FlxTypedGroup<Turret>;
	public var mobs:FlxTypedGroup<Mob>;
	public var bullets:FlxTypedGroup<Bullet>;
	public var pickables:FlxTypedGroup<Pickable>;
	public var pickablesHUD:FlxTypedGroup<Pickable>;
	
	var hud:HUDBar;
	
	var entities:FlxGroup;
	var level:Level;
	
	var currentLevelIdx: Int;
	var levelDataTable:LevelDataTable;
	var entityLibrary:EntityLibrary;
	
	var result:Result;
	public var levelOverSignal:FlxTypedSignal<Result -> Void>;
	
	public var addedFood:FlxTypedSignal<Int -> Void>;
	public var usedFood:FlxTypedSignal<Int -> Void>;
	
	var waveTimer:FlxTimer;
	var spawnTimer:FlxTimer;
	public var currentWaveIdx:Int;
	var currentSpawnIdx:Int;
	public var waves:Array<WaveData>;
	var allWavesSpawned:Bool;
	
	var turretData:TurretData;
	
	public var turretVFX:FlxGroup;
	
	public var totalElapsed:Float;
	
	public var nutrientAmount:Int;
	
	public var nutrientGivenPerClick:Int = 10;

	
	// var projectiles:flxgroup, etc
	
	override public function create():Void
	{
		super.create();

		FlxG.mouse.visible = true;
		
		bgColor = 0xff330033; // ARGB?
		currentLevelIdx = 0;
		
		loadLevelTable();
		
		entityLibrary = new EntityLibrary("assets/data/entities.json");
		turretData = entityLibrary.getTurretById(0);

		
		gameGroup = new FlxGroup();
		add(gameGroup);
		
		hud = new HUDBar(this);
		add(hud);
		
		addedFood = new FlxTypedSignal<Int->Void>();
		usedFood = new FlxTypedSignal<Int->Void>();
		levelOverSignal = new FlxTypedSignal<Result->Void>();
		
		entities = new FlxGroup();
		mobs = new FlxTypedGroup<Mob>();
		turrets = new FlxTypedGroup<Turret>();
		bullets = new FlxTypedGroup<Bullet>();
		turretVFX = new FlxGroup();
		pickables = new FlxTypedGroup<Pickable>();
		pickablesHUD = new FlxTypedGroup<Pickable>();
		
		loadLevelByIdx(currentLevelIdx);		

		
		result = Result.Running;
		totalElapsed = 0;
	}
	
	public function loadLevelByIdx(idx:Int):Void
	{
		var level:LevelJson = levelDataTable.getLevelAt(idx);
		loadLevel(level);
	}
	
	public function loadLevel(levelJson:LevelJson):Void
	{
		if (gameGroup != null)
		{
			if (level != null)
			{
				gameGroup.remove(level.background, true);
				gameGroup.remove(level.foreground, true);
				level.destroy();		
				level = null;
			}
			
			if (entities != null)
			{
				gameGroup.remove(entities, true);
				for (obj in entities)
				{
					obj.destroy();
				}
				entities.clear();
			}
			
			if (bullets != null)
			{
				gameGroup.remove(bullets, true);
				for (obj in bullets)
				{
					obj.destroy();
				}
				bullets.clear();
			}
			
			if (turretVFX != null)
			{
				gameGroup.remove(turretVFX, true);
				for (tVfx in turretVFX)
				{
					tVfx.destroy();
				}
				turretVFX.clear();
			}
		}		
		
		level = new Level(levelJson.levelTMXPath, this);		
		gameGroup.add(level.background);
		gameGroup.add(entities);
		//gameGroup.add(level.foreground);
		gameGroup.add(bullets);
		var playerPos:FloatVec2 = level.playerPos;
		
		gameGroup.add(turretVFX);
		gameGroup.add(pickablesHUD);

		
		pet = new Pet(playerPos.x, playerPos.y, entityLibrary.defaultPet, this);
		pet.died.add(onPetDied);
		pet.damaged.add(onPetGotDamaged);
		
		mobs.clear();
		turrets.clear();

		entities.add(pickables);
		entities.add(pet);
		entities.add(turrets);
		entities.add(mobs);
		
	
		waveTimer = new FlxTimer();
		spawnTimer = new FlxTimer();

		waves = levelJson.waves;
		currentWaveIdx = 0;
		allWavesSpawned = false;
		waveTimer.start(waves[currentWaveIdx].timeMarker, onWaveTick);
		
				
		nutrientAmount = levelJson.startFood;
		hud.init();

	}
	
	function onWaveTick(timer:FlxTimer):Void
	{
		currentSpawnIdx = 0;				
		nextSpawn();	
	}
	
	function onSpawnTick(timer:FlxTimer):Void
	{
		nextSpawn();
	}
	
	function nextSpawn():Void
	{
		var wave:WaveData = waves[currentWaveIdx];
		
		spawnMob(wave.mobs[currentSpawnIdx], wave.mobSpawn);
		if (currentSpawnIdx == wave.mobs.length - 1)
		{ 
			spawnTimer.cancel();
			if (currentWaveIdx == waves.length - 1)
			{
				waveTimer.cancel();
				allWavesSpawned = true;
			}
			else
			{
				var delta:Float = waves[currentWaveIdx + 1].timeMarker - waves[currentWaveIdx].timeMarker;
				waveTimer.reset(delta);				
			}
			currentWaveIdx++;
		}
		else
		{
			currentSpawnIdx++;
			spawnTimer.cancel();
			spawnTimer.start(wave.spawnDelay, onSpawnTick);
		}
	}
	
	function spawnMob(mobId:Int, mobSpawnPos:String):Void
	{
		var mobPos:FloatVec2 = level.getSpawnPos(mobSpawnPos);
		var randomMob: Mob = new Mob(mobPos.x, mobPos.y, entityLibrary.getMobById(mobId), this);
		mobs.add(randomMob);
		randomMob.goTo(pet, level);
		randomMob.destroyedByBullet.add(onMobGotKilled);
		randomMob.died.add(onMobDied);
	}
	
	
	private function loadLevelTable():Void
	{
		levelDataTable = new LevelDataTable("assets/data/levels.json");
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
		
		if (FlxG.keys.firstJustReleased() == FlxKey.ESCAPE)
		{
			FlxG.switchState(new PlayState());
			return;
		}
		
		if (result != Result.Running)		
		{
			// TODO: Game over transition logic
			return;
		}
		
		totalElapsed += elapsed;
		
		if (FlxG.mouse.justReleased)
		{
			var pos:FlxPoint = FlxG.mouse.getPosition();
			
			if (pet.overlapsPoint(pos) && nutrientAmount >= nutrientGivenPerClick)
			{
				nutrientAmount -= nutrientGivenPerClick;
				usedFood.dispatch(nutrientGivenPerClick);
				pet.giveFood(nutrientGivenPerClick);
			}
			
			
			var coords:IntVec2 = level.coordsFromPos({x:pos.x, y:pos.y});
			
			if (level.isValidTurretRect(coords, turretData.width, turretData.height, turrets))
			{
				if (nutrientAmount >= turretData.foodCost)
				{
					var posBis:FloatVec2 = level.posFromCoords(coords);
					var turret:Turret = new Turret(posBis.x, posBis.y, turretData, this);
					turrets.add(turret);
					nutrientAmount -= turretData.foodCost;
					usedFood.dispatch(turretData.foodCost);
				}
				else
				{
					FlxG.log.add("Not enough food!");
				}
			}

		}
		
		
		
		
		for (mob in mobs)
		{
			FlxG.collide(mob, level.navigationMap);
			FlxG.overlap(mob, pet, mobPetCollision);
		}
		
		FlxG.overlap(bullets, mobs, onBulletHitMob);
		
				
		if (allWavesSpawned && mobs.countLiving() <= 0 && pet.hp > 0)
		{
			setResult(Result.Won);
		}
	}
	
	function setResult(levelResult:Result):Void
	{
		result = levelResult;
		var resultStyle:LogStyle = new LogStyle("[RESULT]","eebbff",12);
		if (levelResult == Result.Lost)
		{
			FlxG.log.advanced("Game lost!", resultStyle);
		}
		else if (levelResult == Result.Won)
		{
			FlxG.log.advanced("Game won!", resultStyle);
		}
		
		for (mob in mobs)
		{
			mob.stop();
		}
		
		waveTimer.cancel();
		spawnTimer.cancel();
		levelOverSignal.dispatch(result);
	}
	
	function onPetDied(pet:Character):Void
	{
		entities.remove(pet, true);
		setResult(Result.Lost);
	}
	
	function onPetGotDamaged(pet:Character, amount:Int):Void
	{
		FlxG.log.add('Ouch! pet took ${amount} damage. current hp: ${pet.hp}');
	}
	
	function mobPetCollision(obj1:FlxObject, obj2:FlxObject):Void
	{
		var mob:Mob = cast obj1;
		var pet:Pet = cast obj2;
		
		mob.petHit();
		
		pet.takeDamage(mob.damage);
	}
	
	function onBulletHitMob(obj1:FlxObject, obj2:FlxObject):Void
	{
		var bullet:Bullet = cast obj1;
		var mob:Mob = cast obj2;
		bullet.onHit();
		mob.hitByBullet(bullet);
	}
	
	function onMobGotKilled(mob:Mob):Void
	{			
		var rnd:FlxRandom = new FlxRandom();
		if (rnd.bool(mob.spawnChance))
		{
			var amount:Int = rnd.int(mob.spawnMin, mob.spawnMax);
			var pos:FlxPoint = mob.getMidpoint();
			var pickable:Pickable = new Pickable(pos.x, pos.y, mob.spawnType, amount, this);
			pickables.add(pickable);
		}
	}
	
	function onMobDied(mobChar:Character):Void
	{
		var mob:Mob = cast mobChar;
		entities.remove(mob, true);
		mobs.remove(mob, true);
		FlxG.log.add('Some mob died');

	}
	
	public function shootBullet(pos:FlxPoint, target:Mob, bulletData:ProjectileData):Void
	{
		var bullet:Bullet = new Bullet(pos.x, pos.y, bulletData, target);
		bullet.destroyed.add(onBulletDestroyed);
		bullets.add(bullet);
	}
	
	function onBulletDestroyed(bullet:Bullet):Void
	{
		bullets.remove(bullet);
	}
	
	public function autoPick(pickable:Pickable):Void
	{
		if (pickable.type == "food")
		{
			var grabbedFood:FlxTween-> Void = function(parameter0:FlxTween):Void {
				nutrientAmount += pickable.amount;
				addedFood.dispatch(pickable.amount);
				pickablesHUD.remove(pickable, true);
				pickable.kill();
			}
			
			pickables.remove(pickable, true);
			pickablesHUD.add(pickable);
			FlxTween.tween(pickable, {x:hud.foodTarget.x, y:hud.foodTarget.y}, 0.8, { ease:FlxEase.cubeOut , onComplete: grabbedFood});			
		}

	}
	
	
}