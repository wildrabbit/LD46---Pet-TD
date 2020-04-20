package org.wildrabbit.pettd.ui;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import flixel.util.FlxSignal.FlxTypedSignal;
import org.wildrabbit.pettd.PlayState;
import flixel.text.FlxText;

/**
 * ...
 * @author wildrabbit
 */
class InteractionButton extends FlxSpriteGroup
{
	public var interaction:String;
	public var interactionCost:Int;
	public var btn:FlxButton;
	public var cost:FlxText;
	public var costIcon:FlxSprite;
	
	public var parent:PlayState;
	
	public function new(X:Float, Y:Float, startOn:Bool, onIconGfx:FlxGraphicAsset, interaction:String, interactionCost:Int, parent:PlayState) 
	{
		super(X, Y);
		
		this.parent = parent;
		this.parent.addedFood.add(updateState);
		this.parent.usedFood.add(updateState);

		this.interaction = interaction;
		this.interactionCost = interactionCost;
		
		btn = new FlxButton(0, 0, "", buttonClicked);		
		btn.loadGraphic(onIconGfx, true, 64, 64); // 32, 32, FlxColor.TRANSPARENT);
		add(btn);
		remove(btn.label);
		btn.label.destroy();
		btn.label = null;
		
		cost = new FlxText(0, 0, 64, '${interactionCost}', 16);
		add(cost);
		cost.alignment = FlxTextAlign.CENTER;
		cost.x = x + (btn.width - cost.width) * 0.5;
		cost.y = y + btn.height + 4;


		resetState();
	}
	
	
	function updateState(amount:Int):Void
	{
		resetState();
	}
	
	function buttonClicked():Void
	{
		parent.interactionButtonClicked(this);
	}
	
	public function resetState():Void
	{
		var canUse:Bool = parent.nutrientAmount >= interactionCost;
		if (canUse)
		{
			btn.active = true;
			btn.alpha = 1;
		}
		else
		{
			btn.active = false;
			btn.alpha = 0.5;
			btn.status = FlxButton.NORMAL;
		}
	}

}