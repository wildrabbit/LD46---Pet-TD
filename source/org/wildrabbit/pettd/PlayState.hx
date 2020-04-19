package org.wildrabbit.pettd;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.math.FlxPoint;
import flixel.util.FlxSignal;
import flixel.util.FlxTimer;
import haxe.macro.Expr.Var;
import org.wildrabbit.pettd.entities.Bullet;
import org.wildrabbit.pettd.entities.EntityLibrary;
import org.wildrabbit.pettd.entities.Character;
import org.wildrabbit.pettd.entities.Mob;
import org.wildrabbit.pettd.entities.Pet;
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
	
	var hud:HUDBar;
	
	var entities:FlxGroup;
	var level:Level;
	
	var currentLevelIdx: Int;
	var levelDataTable:LevelDataTable;
	var entityLibrary:EntityLibrary;
	
	var result:Result;
	public var levelOverSignal:FlxTypedSignal<Result -> Void>;
	
	var waveTimer:FlxTimer;
	var spawnTimer:FlxTimer;
	public var currentWaveIdx:Int;
	var currentSpawnIdx:Int;
	public var waves:Array<WaveData>;
	var allWavesSpawned:Bool;
	
	var turretData:TurretData;
	
	public var turretVFX:FlxGroup;
	
	public var totalElapsed:Float;
	
	// var projectiles:flxgroup, etc
	
	override public function create():Void
	{
		super.create();

		
		
		FlxG.mouse.visible = true;
		
		bgColor = 0xff330033; // ARGB?
		currentLevelIdx = 0;
		
		loadLevelTable();
		
		entityLibrary = new EntityLibrary("assets/data/entities.json");
		
		gameGroup = new FlxGroup();
		add(gameGroup);
		
		hud = new HUDBar(this);
		add(hud);
		
		entities = new FlxGroup();
		mobs = new FlxTypedGroup<Mob>();
		turrets = new FlxTypedGroup<Turret>();
		bullets = new FlxTypedGroup<Bullet>();
		turretVFX = new FlxGroup();
		loadLevelByIdx(currentLevelIdx);		

		
		result = Result.Running;
		
		levelOverSignal = new FlxTypedSignal<Result->Void>();
		
		turretData = entityLibrary.getTurretById(0);
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
		
		pet = new Pet(playerPos.x, playerPos.y, entityLibrary.defaultPet);
		pet.died.add(onPetDied);
		pet.damaged.add(onPetGotDamaged);
		
		mobs.clear();
		turrets.clear();

		entities.add(pet);
		entities.add(turrets);
		entities.add(mobs);
	
		waveTimer = new FlxTimer();
		spawnTimer = new FlxTimer();

		waves = levelJson.waves;
		currentWaveIdx = 0;
		allWavesSpawned = false;
		waveTimer.start(waves[currentWaveIdx].timeMarker, onWaveTick);
		
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
		var randomMob: Mob = new Mob(mobPos.x, mobPos.y, entityLibrary.getMobById(mobId));
		mobs.add(randomMob);
		randomMob.goTo(pet, level);
		randomMob.died.add(onMobDied);
	}
	
	
	private function loadLevelTable():Void
	{
		levelDataTable = new LevelDataTable("assets/data/levels.json");
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
		
		if (result != Result.Running)		
		{
			// TODO: Game over transition logic
			return;
		}
		
		totalElapsed += elapsed;
		
		if (FlxG.mouse.justReleased)
		{
			var pos:FlxPoint = FlxG.mouse.getPosition();
			var coords:IntVec2 = level.coordsFromPos({x:pos.x, y:pos.y});
			
			if (level.isValidTurretRect(coords, turretData.width, turretData.height, turrets))
			{
				var posBis:FloatVec2 = level.posFromCoords(coords);
				var turret:Turret = new Turret(posBis.x, posBis.y, turretData, this);
				turrets.add(turret);
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
		if (levelResult == Result.Lost)
		{
			trace("Game lost!");
		}
		else if (levelResult == Result.Won)
		{
			trace("Game won!");
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
		trace('Ouch! pet took ${amount} damage. current hp: ${pet.hp}');
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
		mob.takeDamage(bullet.dmg);
	}
	
	function onMobDied(mobChar:Character):Void
	{
		var mob:Mob = cast mobChar;
		entities.remove(mob, true);
		mobs.remove(mob, true);
		trace('Some mob died');
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
}