package org.wildrabbit.pettd.ui;

import flixel.FlxG;
import flixel.FlxState;
import flixel.group.FlxGroup;
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
		
		parent.pet.damaged.add(updateHP);
		
		updateTimer.start(1, timerTicked, 0);
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
	
}