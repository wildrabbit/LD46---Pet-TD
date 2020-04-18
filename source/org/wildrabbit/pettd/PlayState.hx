package org.wildrabbit.pettd;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import org.wildrabbit.pettd.Level;


import flixel.FlxState;

class PlayState extends FlxState
{
	// TODO: Check what groups we need here.
	
	var pet:FlxSprite; // Pet.
	var turrets:Array <FlxSprite>;
	var entities:FlxGroup;
	var level:Level;
	// var projectiles:flxgroup, etc
	
	override public function create():Void
	{
		super.create();
		
		FlxG.mouse.visible = true;
		
		bgColor = 0xff330033; // ARGB?
		
		entities = new FlxGroup();

		level = new Level("assets/data/test-level.tmx", this);
		add(level.background);
		add(level.foreground);
		
		// TODO: Create UI, stuff
		
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
	}
}