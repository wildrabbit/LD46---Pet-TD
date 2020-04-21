package org.wildrabbit.pettd;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.addons.editors.ogmo.FlxOgmo3Loader.LevelData;
import flixel.group.FlxGroup;
import flixel.input.keyboard.FlxKey;
import flixel.math.FlxPoint;
import flixel.math.FlxRandom;
import flixel.system.debug.log.LogStyle;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxSignal;
import flixel.util.FlxSort;
import flixel.util.FlxTimer;
import haxe.macro.Expr.Var;
import org.wildrabbit.pettd.entities.Bullet;
import org.wildrabbit.pettd.entities.EntityLibrary;
import org.wildrabbit.pettd.entities.Character;
import org.wildrabbit.pettd.entities.Mob;
import org.wildrabbit.pettd.entities.Pet;
import org.wildrabbit.pettd.entities.Pickable;
import org.wildrabbit.pettd.entities.Turret;
import org.wildrabbit.pettd.ui.GameWonState;
import org.wildrabbit.pettd.ui.HUDBar;
import org.wildrabbit.pettd.ui.InteractionButton;
import org.wildrabbit.pettd.ui.TurretButton;
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
	public var mobsVFX:FlxTypedGroup<FlxSprite>;
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
	
	
	public var turretVFX:FlxGroup;
	
	public var totalElapsed:Float;
	
	public var nutrientAmount:Int;
	
	public var nutrientGivenPerClick:Int = 10;
	
	public var placingMode:Bool = false;
	public var turretPreview:FlxSprite;
	public var selectedTurretData:TurretData;

	
	public var turretButtons:FlxTypedGroup<TurretButton>;
	
	public var restartReady:Bool;
	
	public var showTurretArea:Bool;
	
	public function new(?startIdx:Int = 0) :Void
	{
		super();
		currentLevelIdx = startIdx;
	}
	
	public var mobVFXTable:Map<Mob,FlxSprite>;
	
	var hudCamera:FlxCamera;
	var mainCamera:FlxCamera;
	
	public var levelName:String;
	
	
	// var projectiles:flxgroup, etc
	
	override public function create():Void
	{
		super.create();

		FlxG.mouse.visible = true;
		
		hudCamera = new FlxCamera(0, 0, FlxG.width, FlxG.height);
		hudCamera.bgColor = FlxColor.TRANSPARENT;
		mainCamera = new FlxCamera(0, 0, 640, 480);
		mainCamera.bgColor = 0xff330033;
		
		FlxG.cameras.reset(mainCamera);
		FlxG.cameras.add(hudCamera);
		FlxCamera.defaultCameras = [mainCamera];
		
		
		loadLevelTable();
		
		entityLibrary = new EntityLibrary("assets/data/entities.json");
		
		gameGroup = new FlxGroup();
		add(gameGroup);
		
		hud = new HUDBar(this);
		hud.cameras = [hudCamera];
		add(hud);
		
		addedFood = new FlxTypedSignal<Int->Void>();
		usedFood = new FlxTypedSignal<Int->Void>();
		levelOverSignal = new FlxTypedSignal<Result->Void>();
		
		entities = new FlxGroup();
		mobs = new FlxTypedGroup<Mob>();
		mobsVFX = new FlxTypedGroup<FlxSprite>();
		turrets = new FlxTypedGroup<Turret>();
		bullets = new FlxTypedGroup<Bullet>();
		turretVFX = new FlxGroup();
		pickables = new FlxTypedGroup<Pickable>();
		pickablesHUD = new FlxTypedGroup<Pickable>();
		pickablesHUD.cameras = [hudCamera];
		turretButtons = new FlxTypedGroup<TurretButton>();
		turretButtons.cameras = [hudCamera];
		
		mobVFXTable = new Map<Mob, FlxSprite>();
		
		loadLevelByIdx(currentLevelIdx);		

		
		result = Result.Running;
		totalElapsed = 0;
		restartReady = false;
		showTurretArea = true;
	}
	
	public function loadLevelByIdx(idx:Int):Void
	{
		var level:LevelJson = levelDataTable.getLevelAt(idx);
		levelName = 'Level ${idx + 1}';
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
			
			if (turretButtons != null)
			{
				gameGroup.remove(turretButtons, true);
				for (tVfx in turretButtons)
				{
					tVfx.destroy();
				}
				turretButtons.clear();
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
		
		mobVFXTable.clear();
		
		mobs.clear();
		mobsVFX.clear();
		turrets.clear();

		entities.add(pickables);
		entities.add(pet);
		entities.add(turrets);
		entities.add(mobsVFX);		
		entities.add(mobs);
		
	
		waveTimer = new FlxTimer();
		spawnTimer = new FlxTimer();

		waves = levelJson.waves;
		currentWaveIdx = 0;
		allWavesSpawned = false;
		waveTimer.start(waves[currentWaveIdx].timeMarker, onWaveTick);
		
				
		nutrientAmount = levelJson.startFood;
		hud.init();
		
		gameGroup.add(turretButtons); // move to ui
		
		buildTurretButtons(levelJson.allowedTurrets);
		buildInteractionButtons();
		
		placingMode = false;
		selectedTurretData = null;
		turretPreview = null;

	}
	
	function buildTurretButtons(turretIDs:Array<Int>):Void
	{
		var startX:Int = FlxG.width - 128 + 16;
		var startY:Int = 128;
		var offset:Int = 8;
		
		for (id in turretIDs)
		{
			var data:TurretData = entityLibrary.getTurretById(id);
			if (data != null)
			{
				var btn:TurretButton = new TurretButton(startX, startY, data, this);
				btn.cameras = [hudCamera];
				turretButtons.add(btn);
				startX += Math.floor(btn.width) + offset;
			}

		}
	}
	
	public function turretButtonClicked(data:TurretData):Void
	{
		var coords:IntVec2 = level.coordsFromPos({x:FlxG.mouse.x, y:FlxG.mouse.y});
		var posBis:FloatVec2 = level.posFromCoords(coords);
					
		
		if (placingMode)
		{
			if (selectedTurretData == data)
			{
				turretPreview.destroy();
				turretPreview = null;
				remove(turretPreview);
				placingMode = false;
			}
			else
			{
				selectedTurretData = data;
				turretPreview.destroy();
				remove(turretPreview);
				turretPreview = new FlxSprite(posBis.x, posBis.y, data.uiGraphic);
				add(turretPreview);
			}
		}
		else
		{
			placingMode = true;
			turretPreview = new FlxSprite(posBis.x, posBis.y, data.uiGraphic);
			add(turretPreview);
			selectedTurretData = data;
		}
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
		mobs.sort(FlxSort.byY);
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
		
		var firstReleased:Int = FlxG.keys.firstJustReleased();
		if (firstReleased == FlxKey.ESCAPE)
		{
			FlxG.switchState(new PlayState(0));
			return;
		}
		if (firstReleased == FlxKey.R)
		{
			FlxG.switchState(new PlayState(currentLevelIdx));
			return;
		}
		
		if (firstReleased == FlxKey.F1)
		{
			if (showTurretArea)
			{
				turretVFX.visible = false;
				showTurretArea = false;
			}
			else
			{
				turretVFX.visible = true;
				showTurretArea = true;
			}
		}
		
		if (result != Result.Running)		
		{
			if (restartReady && (FlxG.keys.firstJustPressed() >= 0 || FlxG.mouse.justPressed))
			{
				if (result == Won)
				{
					if (currentLevelIdx == levelDataTable.numLevels - 1)
					{
						FlxG.switchState(new GameWonState());
					}
					else
					{
						FlxG.switchState(new PlayState(currentLevelIdx + 1));	
					}					
				}
				else
				{
					FlxG.switchState(new PlayState(currentLevelIdx));
				}
			}
			return;
		}
		
		totalElapsed += elapsed;
		
		if (placingMode)
		{
			var pos:FlxPoint = FlxG.mouse.getPositionInCameraView(mainCamera);
			var coords:IntVec2 = level.coordsFromPos({x:pos.x, y:pos.y});
			var posBis:FloatVec2 = level.posFromCoords(coords);
			var valid:Bool = level.isValidTurretRect(coords, selectedTurretData.width, selectedTurretData.height, turrets);
			var hasFood:Bool = selectedTurretData.foodCost <= nutrientAmount;
				
			if (FlxG.mouse.justMoved)
			{
				turretPreview.setPosition(posBis.x, posBis.y);
				turretPreview.color = valid ? turretPreview.color = 0xfff6da63 : 0xff9d0b0b;
			}
			else if (FlxG.mouse.justPressed && valid && hasFood)
			{
				createTurret(FlxPoint.weak(posBis.x, posBis.y), selectedTurretData);
				
				selectedTurretData = null;
				turretPreview.destroy();
				remove(turretPreview);
				placingMode = false;
			}
		}
		else
		{
			var pos:FlxPoint = FlxG.mouse.getPositionInCameraView(mainCamera);
				
			if (FlxG.mouse.justReleased)
			{
				
				if (pet.overlapsPoint(pos) && nutrientAmount >= nutrientGivenPerClick)
				{
					nutrientAmount -= nutrientGivenPerClick;
					usedFood.dispatch(nutrientGivenPerClick);
					pet.giveFood(nutrientGivenPerClick);
				}				
			}
			
			if (FlxG.mouse.justMoved)
			{
				for (pickable in pickables)
				{
					if (pickable.overlapsPoint(pos))
					{
						pickable.collect();
					}
				}
			}
			
		}
		
		
		
		
		for (mob in mobs)
		{
			FlxG.collide(mob, level.navigationMap);
			FlxG.overlap(mob, pet, mobPetCollision);
			if (mobVFXTable.exists(mob))
			{
				mobVFXTable[mob].setPosition(mob.x, mob.y);
			}
		}
		
		FlxG.overlap(bullets, mobs, onBulletHitMob);
		
				
		if (allWavesSpawned && mobs.countLiving() <= 0 && pet.hp > 0)
		{
			setResult(Result.Won);
		}
	}
	
	function createTurret(pos:FlxPoint, data:TurretData):Void
	{
		var turret:Turret = new Turret(pos.x, pos.y, data, this);
		turrets.add(turret);
		nutrientAmount -= data.foodCost;
		usedFood.dispatch(data.foodCost);
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
		
		var timer:FlxTimer = new FlxTimer();
		timer.start(2, function(parameter0:FlxTimer):Void { restartReady = true; });
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
		
		pet.hitByMob(mob.damage);
		
		
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

	public function addMobVFX(vfx:FlxSprite, mob:Mob):Void
	{
		if (!mobVFXTable.exists(mob))
		{
			mobVFXTable[mob] = vfx;
			mobsVFX.add(vfx);
		}
	}
	
	public function removeMobVFX(mob:Mob):Void
	{
		if (mobVFXTable.exists(mob))
		{
			mobsVFX.remove(mobVFXTable[mob]);
			mobVFXTable.remove(mob);
		}
	}
	
	public function interactionButtonClicked(btn:InteractionButton):Void
	{
		if(btn.interaction == "feed" && nutrientAmount >= nutrientGivenPerClick)
		{
			nutrientAmount -= nutrientGivenPerClick;
			usedFood.dispatch(nutrientGivenPerClick);
			pet.giveFood(nutrientGivenPerClick);
		}
	}
	
	function buildInteractionButtons():Void
	{
		var startX:Int = FlxG.width - 128 + 32;
		var startY:Int = 224;
		var offset:Int = 8;
		
		var feedButton:InteractionButton = new InteractionButton(startX, startY, false, "assets/images/feed-btn.png", "feed", nutrientGivenPerClick, this);
		hud.add(feedButton);
	}
	
}