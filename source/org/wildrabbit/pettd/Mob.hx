package org.wildrabbit.pettd;

import org.wildrabbit.pettd.AssetPaths;
import org.wildrabbit.pettd.Character;

/**
 * ...
 * @author wildrabbit
 */
class Mob extends Character 
{

	public function new(?X:Float=0, ?Y:Float=0) 
	{
		var mobData = {
			"sheetFile":AssetPaths.proto_mob__png,
			"atlasFile":AssetPaths.proto_mob__json,
			"prefix":"proto-mob",
			"postfix":".aseprite",
			"anims":[{"name":"idle", "frames":[0,1], "fps":3}],
			"defaultAnim":"idle"
		};
		super(X, Y, mobData);
	}
	
}