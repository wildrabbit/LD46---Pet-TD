package org.wildrabbit.pettd;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import haxe.macro.Expr.Var;
import org.wildrabbit.pettd.world.Level;
import org.wildrabbit.pettd.world.LevelDataTable;


import flixel.FlxState;

class PlayState extends FlxState
{
	// TODO: Check what groups we need here.
	
	var gameGroup:FlxGroup;
	
	var pet:FlxSprite; // Pet.
	var turrets:Array <FlxSprite>;
	
	var entities:FlxGroup;
	var level:Level;
	
	var currentLevelIdx: Int;
	var levelDataTable:LevelDataTable;
	// var projectiles:flxgroup, etc
	
	override public function create():Void
	{
		super.create();
		
		FlxG.mouse.visible = true;
		
		bgColor = 0xff330033; // ARGB?
		currentLevelIdx = 0;
		
		loadLevelTable();
		
		gameGroup = new FlxGroup();
		add(gameGroup);
		
		
		loadLevelByIdx(currentLevelIdx);		
	}
	
	public function loadLevelByIdx(idx:Int):Void
	{
		var level:LevelJson = levelDataTable.getLevelAt(idx);
		loadLevel(level);
		// TODO: Set level data.
	}
	
	public function loadLevel(levelJson:LevelJson):Void
	{
		if (gameGroup != null)
		{
			if (level != null)
			{
				gameGroup.remove(level.background);
				gameGroup.remove(level.foreground);
				level.destroy();		
				level = null;
			}
			
			for (obj in gameGroup)
			{
				obj.destroy();
			}
			gameGroup.clear();
		}		
		
		level = new Level(levelJson.levelTMXPath, this);		
		gameGroup.add(level.background);
		gameGroup.add(level.foreground);
		// TODO: Reset Entities
		
		// TODO: Reset HUD
		
	}
	
	private function loadLevelTable():Void
	{
		levelDataTable = new LevelDataTable("assets/data/levels.json");
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
	}
}