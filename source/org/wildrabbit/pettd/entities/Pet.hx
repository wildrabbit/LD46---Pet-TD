package org.wildrabbit.pettd.entities;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxTimer;
import org.wildrabbit.pettd.AssetPaths;
import org.wildrabbit.pettd.PlayState;
import org.wildrabbit.pettd.entities.Character.CharacterData;

typedef PetData = 
{
	var characterData: CharacterData;
	
	var foodWarningThreshold:Float;
	var foodHappyThreshold:Float;
	
	var foodHPDepletionRate:Int;
	var foodHPDepletionSecs:Float;
	
		
	var foodHPRegenRate:Int;
	var foodHPRegenSecs:Float;
	
	var foodConsumptionRate:Int;
	var foodConsumptionSecs:Float;
	
	var foodMaxCapacity:Int;
	var foodStartCapacity:Int;
}


/**
 * ...
 * @author wildrabbit
 */
class Pet extends Character 
{

	public var foodWarningThreshold:Float;
	public var foodHappyThreshold:Float;
	public var foodHappyRegenRate:Int;
	public var foodHappyRegenSecs:Float;
	public var foodHPDepletionRate:Int;
	public var foodHPDepletionSecs:Float;
	public var foodConsumptionRate:Int;
	public var foodConsumptionSecs:Float;
	public var foodMax:Int;
	
	var foodCount:Int;
	
	var foodRatio(get, null):Float;
	
	function get_foodRatio():Float
	{
		return foodCount / cast foodMax;
	}
	
	var hpTimer:FlxTimer;
	var foodTimer:FlxTimer;
	

	public function new(?X:Float=0, ?Y:Float=0, petData:PetData, root:PlayState) 
	{
		super(X, Y, petData.characterData, root);
		
		root.levelOverSignal.add(onLevelOver);
		
		foodCount = petData.foodStartCapacity;
		foodMax = petData.foodMaxCapacity;
		
		foodWarningThreshold = petData.foodWarningThreshold;
		foodHappyThreshold = petData.foodHappyThreshold;
		
		foodHPDepletionRate = petData.foodHPDepletionRate;
		foodHPDepletionSecs = petData.foodHPDepletionSecs;
		
		foodConsumptionRate = petData.foodConsumptionRate;
		foodConsumptionSecs = petData.foodConsumptionSecs;
		
		foodHappyRegenRate = petData.foodHPRegenRate;
		foodHappyRegenSecs = petData.foodHPRegenSecs;
		
		hpTimer = new FlxTimer();
		foodTimer = new FlxTimer();
		
		foodTimer.start(foodConsumptionSecs, onConsumeFoodTick);
		
		
		if (foodRatio == 0)
		{
			hpTimer.start(foodHPDepletionSecs, onDepleteHPTick);
		}
	}
	
	function onLevelOver(result:Result):Void
	{
		hpTimer.cancel();
		foodTimer.cancel();
	}
	
	public function foodWarning():Bool
	{
		return foodRatio < foodWarningThreshold;
	}
	
	public function foodHappy():Bool
	{
		return foodRatio >= foodHappyThreshold;
	}
	
	public function onConsumeFoodTick(t:FlxTimer):Void
	{
		var delta:Int = (foodCount < foodConsumptionRate) ? foodCount :foodConsumptionRate;
		foodCount -= delta;
		
		FlxG.log.add('Digested ${delta} so now I\'m at ${foodCount}/${foodMax} now');
		
		
		if (foodCount == 0)
		{
			foodTimer.cancel();
			hpTimer.start(foodHPDepletionSecs, onDepleteHPTick);
			if(animation.curAnim.name != "damaged")
				animation.play("damaged");
		}
		else if (foodRatio < foodWarningThreshold)
		{
			if(animation.curAnim.name != "hungry")
				animation.play("hungry");
		}
		else if (foodRatio < foodHappyThreshold)
		{
			if (hpTimer.active)
			{
				hpTimer.cancel();
			}
			if (animation.curAnim.name == "happy")
			{
				animation.play("idle");	
			}
			
		}
		
		foodTimer.reset(foodConsumptionSecs);
	}
	
	public function onDepleteHPTick(t:FlxTimer):Void
	{
		FlxG.log.add('Hungry >_<');
		takeDamage(foodHPDepletionRate);
		if (hp > 0 && foodRatio == 0)
		{
			hpTimer.reset(foodHPDepletionSecs);
		}
	}
	
	public function onRegenHPTick(t:FlxTimer):Void
	{
		FlxG.log.add('Healing! =)');
		takeDamage(foodHappyRegenRate);
		if (hp > 0 && foodHappy())
		{
			hpTimer.reset(foodHappyRegenSecs);
		}
	}
	
	public function giveFood(amount:Int):Void
	{
		var wasHappy: Bool = foodHappy();
		foodCount += amount;
		if (foodCount > foodMax)
		{
			foodCount = foodMax;
		}
		
		FlxG.log.add('Yummy! I ate ${amount} so now I\'m at ${foodCount}/${foodMax}');
		
		
		if (!foodTimer.active)
		{
			foodTimer.start(foodConsumptionSecs, onConsumeFoodTick);
		}
		
		if (hp > 0 && hpTimer.active)
		{
			hpTimer.cancel();
		}

		
		if (foodRatio > foodWarningThreshold)
		{
			if (animation.curAnim.name != "idle")
			{			
				animation.play("idle");
			}
			if (!wasHappy && foodHappy())
			{
				FlxG.log.add('Healing! =)');
				hpTimer.start(foodHappyRegenRate, onRegenHPTick);
				animation.play("happy");
			}
		}
		
		
		
	}
	
}