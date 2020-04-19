package org.wildrabbit.pettd.entities;

import flixel.FlxSprite;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.util.FlxTimer;
import org.wildrabbit.pettd.PlayState;

/**
 * ...
 * @author wildrabbit
 */
class Pickable extends FlxSprite
{
	var root:PlayState;
	public var type:String;
	public var amount:Int;
	
	var pickTimer:FlxTimer;
	
	public function new(X:Float=0, Y:Float=0, type:String, amount:Int, root:PlayState)
	{
		this.root = root;
		if (type == "food")
		{
			super(X, Y, "assets/images/proto-food.png");				
		}
		else super(X, Y);
		
		setPosition(x - width / 2, y - height / 2);
		this.amount = amount;
		this.type = type;
		
		pickTimer = new FlxTimer();
		pickTimer.start(1, onTimerComplete);
	}
	
	function onTimerComplete(timer:FlxTimer):Void
	{
		root.autoPick(this);
	}
	
}