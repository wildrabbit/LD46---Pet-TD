package org.wildrabbit.pettd.ui;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxPoint;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.text.FlxText;
import flixel.text.FlxText.FlxTextAlign;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import org.wildrabbit.pettd.PlayState;
import org.wildrabbit.pettd.entities.Turret.TurretData;

/**
 * ...
 * @author wildrabbit
 */
class TurretButton extends FlxSpriteGroup
{
	var data:TurretData;
	var btn:FlxButton;
	var icon:FlxSprite;
	var parent:PlayState;
	var leText:FlxText;
	
	public function new(x:Float, y:Float, turretData:TurretData, state:PlayState):Void
	{
		super(x, y);
		parent = state;
		data = turretData;
		parent.addedFood.add(updateState);
		parent.usedFood.add(updateState);
		
		btn = new FlxButton(0, 0, "", buttonClicked);		
		btn.makeGraphic(32, 32, FlxColor.fromRGB(29,43,83));
		add(btn);
		
		icon = new FlxSprite(0, 0, turretData.uiGraphic);
		icon.scale = FlxPoint.weak(0.5, 0.5);
		icon.updateHitbox();
		icon.x = (btn.width - icon.width) / 2;
		icon.y = (btn.height - icon.height) / 2;
		add(icon);
		
		leText = new FlxText(0, 0, 32, '${data.foodCost}', 16);
		add(leText);
		leText.color = FlxColor.fromRGB(255, 241, 232);
		leText.alignment = FlxTextAlign.CENTER;
		leText.x = x + (btn.width - leText.width) * 0.5;
		leText.y = y + btn.height + 4;
		
		remove(btn.label);
		btn.label.destroy();
		btn.label = null;
		
		
		leText.text = '${data.foodCost}';
		
		setState(parent.nutrientAmount >= turretData.foodCost);
	}
	
	function updateState(amount:Int):Void
	{
		resetState();
	}
	
	function setState(enabled:Bool):Void
	{
		btn.active = enabled;
		icon.alpha = enabled ? 1 : 0.5;
	}
	
	function buttonClicked():Void
	{
		parent.turretButtonClicked(data);
	}
	
	public function resetState():Void
	{
		setState(parent.nutrientAmount >= data.foodCost);
	}
	
}