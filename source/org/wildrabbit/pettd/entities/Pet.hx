package org.wildrabbit.pettd.entities;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.util.FlxSignal.FlxTypedSignal;
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

enum NeedState
{
	Empty;
	Warning;
	Normal;
	Happy;
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
	
	public var foodCount:Int;
	
	public var foodState:NeedState;
	
	var foodRatio(get, null):Float;
	
	function get_foodRatio():Float
	{
		return foodCount / cast foodMax;
	}
	
	var hpTimer:FlxTimer;
	var foodTimer:FlxTimer;
	
	public var stateChanged:FlxTypedSignal<NeedState->Void>;
	public var hungerChanged:FlxTypedSignal<Pet->Void>;
	var oldAnim:String;

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
		
		foodState = NeedState.Normal;
		
		stateChanged = new FlxTypedSignal<NeedState->Void>();
		hungerChanged = new FlxTypedSignal<Pet->Void>();
		
		checkNeedState(true);
	}
	
	function animEnd(aname:String):Void
	{
		if (aname == "hit")
		{
			animation.play(oldAnim);
			oldAnim = "";
			animation.finishCallback = null;
		}
	}
	
	function checkNeedState(?forced:Bool = false):Void
	{
		var oldNeed:NeedState = foodState;
		var nextNeed:NeedState = foodState;
		if (foodCount == 0)
		{
			nextNeed = NeedState.Empty;
		}
		else if (foodWarning())
		{
			nextNeed = NeedState.Warning;
		}
		else if (foodHappy())
		{
			nextNeed = NeedState.Happy;
		}
		else nextNeed = NeedState.Normal;
		
		if (nextNeed == oldNeed && !forced)
		{
			return;
		}
		
		if (nextNeed == NeedState.Empty)
		{
			foodTimer.cancel();
			hpTimer.cancel();
			hpTimer.start(foodHPDepletionSecs, onDepleteHPTick,0);
			animation.play("damaged");
		}
		else if (nextNeed == NeedState.Warning)
		{
			if (!foodTimer.active)
			{
				foodTimer.start(foodConsumptionSecs, onConsumeFoodTick,0);
			}
			if (hpTimer.active)
			{
				hpTimer.cancel();
			}
			animation.play("hungry");
		}
		else if (nextNeed == NeedState.Happy)
		{
			if (!foodTimer.active)
			{
				foodTimer.start(foodConsumptionSecs, onConsumeFoodTick,0);
			}
			
			hpTimer.cancel();
			hpTimer.start(foodHappyRegenSecs, onRegenHPTick,0);
			animation.play("happy");
		}
		else
		{
			if (!foodTimer.active)
			{
				foodTimer.start(foodConsumptionSecs, onConsumeFoodTick,0);
			}
			if (hpTimer.active)
			{
				hpTimer.cancel();
			}
			animation.play("idle");
		}
		
		foodState = nextNeed;
		stateChanged.dispatch(foodState);
	}
	
	function onLevelOver(result:Result):Void
	{
		hpTimer.cancel();
		foodTimer.cancel();
		
		if (result == Result.Lost)
		{
			animation.play("damaged");
		}
		else if (result == Result.Won)
		{
			animation.play("happy");
		}
		
		if (hp == 0) return;
		
		
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
		hungerChanged.dispatch(this);
		
		FlxG.log.add('Digested ${delta} so now I\'m at ${foodCount}/${foodMax} now');
		
		
		checkNeedState();
	}
	
	public function onDepleteHPTick(t:FlxTimer):Void
	{
		FlxG.log.add('Hungry >_<');
		takeDamage(foodHPDepletionRate);
		checkNeedState();
	}
	
	public function hitByMob(mdamage:Int):Void
	{
		takeDamage(mdamage);
		if(animation.curAnim.name != "hit")
			oldAnim = animation.curAnim.name;
		animation.play("hit");
		animation.finishCallback = animEnd;
	}
	
	public function onRegenHPTick(t:FlxTimer):Void
	{
		FlxG.log.add('Healing! =)');
		recoverHealth(foodHappyRegenRate);
		checkNeedState();
	}
	
	public function giveFood(amount:Int):Void
	{
		var wasHappy: Bool = foodHappy();
		foodCount += amount;
		if (foodCount > foodMax)
		{
			foodCount = foodMax;
		}
		hungerChanged.dispatch(this);
		FlxG.log.add('Yummy! I ate ${amount} so now I\'m at ${foodCount}/${foodMax}');
		
		checkNeedState();
	}
	
	
	public function getHungerStatusColour():FlxColor
	{
		if (foodCount == 0)
		{
			return 0xffda2d2d;
		}
		else if (foodWarning())
		{
			return 0xffeb8242;
		}
		else if (foodHappy())
		{
			return 0xfff6da63;
		}
		else return 0xfff6da63; // FlxColor.fromRGB(255, 241, 232);
	}
	
}