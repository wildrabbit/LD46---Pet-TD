package org.wildrabbit.pettd.ui;

import flixel.FlxG;
import flixel.FlxState;
import flixel.group.FlxGroup;
import flixel.input.FlxPointer;
import flixel.math.FlxPoint;
import flixel.text.FlxText;
import flixel.util.FlxStringUtil;
import flixel.util.FlxTimer;
import org.wildrabbit.pettd.PlayState;
import org.wildrabbit.pettd.entities.Character;

/**
 * ...
 * @author wildrabbit
 */
class HUDBar extends FlxGroup 
{
	var hp:FlxText;
	var waveCounter:FlxText;
	var timer:FlxText;
	var food:FlxText;
	
	public var foodTarget:FlxPoint;
	
	var parent:PlayState;
	
	var updateTimer:FlxTimer;
	
	public function new(root:PlayState) 
	{
		super();
		
		parent = root;
		updateTimer = new FlxTimer();
	}
	
	public function init():Void
	{
		hp = new FlxText(FlxG.width - 120, 0, 120, 'HP: ${parent.pet.hp}/${parent.pet.maxHP}', 12);
		add(hp);
		
		timer = new FlxText(0, 0, 120, timerText(parent.totalElapsed), 12);
		add(timer);
		
		waveCounter = new FlxText(124, 0, 240,  waveText(parent.currentWaveIdx, parent.waves.length, parent.waves[parent.currentWaveIdx].timeMarker - parent.totalElapsed), 12);
		add(waveCounter);
		
		food = new FlxText(FlxG.width - 120, 16, 120, 'Food: ${parent.nutrientAmount}', 12);
		add(food);
		
		parent.pet.damaged.add(updateHP);
		parent.addedFood.add(updateFood);
		parent.usedFood.add(updateFood);
		
		updateTimer.start(1, timerTicked, 0);
		
		foodTarget = food.getMidpoint();
	}
	
	function updateHP(pet:Character, delta:Int):Void
	{
		hp.text = 'HP: ${pet.hp}/${pet.maxHP}';
	}
	
	function timerText(elapsed:Float):String
	{
		return 'Time: ${FlxStringUtil.formatTime(elapsed)}';
	}
	
	function timerTicked(leTimer:FlxTimer):Void 
	{
		if (parent.currentWaveIdx == parent.waves.length)
		{
			waveCounter.text = waveText(parent.currentWaveIdx - 1, parent.waves.length, 0);
			leTimer.cancel();
			return;
		}
		timer.text = timerText(parent.totalElapsed);	
		var marker:Float = parent.currentWaveIdx == parent.waves.length ? parent.totalElapsed : parent.waves[parent.currentWaveIdx].timeMarker;
		waveCounter.text = waveText(parent.currentWaveIdx, parent.waves.length, marker - parent.totalElapsed);
	}
	
	function waveText(idx:Int, total:Int, remaining:Float):String
	{
		return 'Wave: ${idx + 1}/${total}, timeTillNext:${FlxStringUtil.formatTime(remaining)}';
	}
	
	function updateFood(delta:Int):Void
	{
		food.text = 'Food: ${parent.nutrientAmount}';
	}
	
}