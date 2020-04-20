package org.wildrabbit.pettd.ui;

import flixel.FlxG;
import flixel.FlxState;
import flixel.group.FlxGroup;
import flixel.input.FlxPointer;
import flixel.math.FlxPoint;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxStringUtil;
import flixel.util.FlxTimer;
import org.wildrabbit.pettd.PlayState;
import org.wildrabbit.pettd.entities.Character;
import org.wildrabbit.pettd.entities.Pet;
import org.wildrabbit.pettd.entities.Pet.NeedState;

/**
 * ...
 * @author wildrabbit
 */
class HUDBar extends FlxGroup 
{
	var level:FlxText;
	var hp:FlxText;
	var waveCounter:FlxText;
	var timer:FlxText;
	var food:FlxText;
	var hunger:FlxText;
	
	public var turretsLabel:FlxText;
	
	public var interactionsLabel:FlxText;
	
	public var foodTarget:FlxPoint;
	
	var parent:PlayState;
	
	var updateTimer:FlxTimer;
	var updateWaves:Bool;
	
	public function new(root:PlayState) 
	{
		super();
		
		parent = root;
		updateTimer = new FlxTimer();
	}
	
	public function init():Void
	{
		var startX:Float = FlxG.width - 128  + 8;
		var startY:Float = 0;
		
		level = new FlxText(startX, startY, 120, parent.levelName, 12);
		level.color = FlxColor.fromRGB(41,173,255);
		add(level);
		startY += level.height + 2;
		
		timer = new FlxText(startX, startY, 120, timerText(parent.totalElapsed), 12);
		add(timer);
		startY += timer.height + 2;
		
		waveCounter = new FlxText(startX, startY, 120,  waveText(parent.currentWaveIdx, parent.waves.length, parent.waves[parent.currentWaveIdx].timeMarker), 12);
		add(waveCounter);
		startY += waveCounter.height + 2;
		waveCounter.wordWrap = true;
		food = new FlxText(startX, startY, 120, 'Food: ${parent.nutrientAmount}', 14);
		food.color = FlxColor.fromRGB(0,228,54);
		food.alignment = FlxTextAlign.CENTER;
		add(food);
		startY += food.height + 4;

		turretsLabel = new FlxText(startX, startY, 120, "Turrets", 12);
		turretsLabel.alignment = FlxTextAlign.CENTER;
		turretsLabel.color = FlxColor.fromRGB(41,173,255);
		add(turretsLabel);
		
		interactionsLabel = new FlxText(startX, startY + 96, 120, "Interactions", 12);
		interactionsLabel.color = FlxColor.fromRGB(41, 173, 255);
		interactionsLabel.alignment = FlxTextAlign.CENTER;
		add(interactionsLabel);
		
		var botStartY:Float = FlxG.height - 64;
		hp = new FlxText(startX, botStartY, 120, 'HP: ${parent.pet.hp}/${parent.pet.maxHP}', 12);
		add(hp);
		botStartY += hp.height + 2;
		
		hunger = new FlxText(startX, botStartY, 120, hungerText(), 12);
		hunger.color = parent.pet.getHungerStatusColour();
		add(hunger);
		
		
		parent.pet.stateChanged.add(updateHungerNeed);
		parent.pet.hungerChanged.add(updateHungerPet);
		parent.pet.damaged.add(updateHP);
		parent.pet.healed.add(updateHP);
		parent.addedFood.add(updateFood);
		parent.usedFood.add(updateFood);
		
		updateWaves = parent.currentWaveIdx < parent.waves.length;
		updateTimer.start(1, timerTicked, 0);
		
		foodTarget = food.getMidpoint();
		
		parent.levelOverSignal.add(onLevelOver);
	}
	
	function hungerText():String
	{
		return 'Hunger: ${parent.pet.foodCount}/${parent.pet.foodMax}';
	}
	
	function updateHP(pet:Character, delta:Int):Void
	{
		hp.text = 'HP: ${pet.hp}/${pet.maxHP}';
	}
	
	function onLevelOver(result:Result):Void
	{
		updateTimer.cancel();
	}
	
	function timerText(elapsed:Float):String
	{
		return 'Time: ${FlxStringUtil.formatTime(elapsed)}';
	}
	
	function timerTicked(leTimer:FlxTimer):Void 
	{
		timer.text = timerText(parent.totalElapsed);	
		updateHunger();
		if (!updateWaves)
		{
			return;
		}

		if (parent.currentWaveIdx == parent.waves.length)
		{
			waveCounter.text = waveText(parent.currentWaveIdx - 1, parent.waves.length, -1);
			updateWaves = false;
			return;
		}
		waveCounter.text = waveText(parent.currentWaveIdx, parent.waves.length, parent.waves[parent.currentWaveIdx].timeMarker);
	}
	
	function waveText(idx:Int, total:Int, marker:Float):String
	{
		return 'Wave: ${idx + 1}/${total}';
		/*if (marker < 0)
		{
			return 'Wave: ${idx + 1}/${total}';
		}
		else
		{
			return 'Wave: ${idx + 1}/${total} \nNext at:${FlxStringUtil.formatTime(marker)}';
		}*/
	}
	
	function updateFood(delta:Int):Void
	{
		food.text = 'Food: ${parent.nutrientAmount}';
	}
	
	function updateHungerNeed(need:NeedState):Void
	{
		updateHunger();
	}
	
	function updateHunger():Void
	{
		hunger.text = hungerText();
		hunger.color = parent.pet.getHungerStatusColour();
	}
	
	function  updateHungerPet(pet:Pet):Void
	{
		updateHunger();
	}
	
	
}