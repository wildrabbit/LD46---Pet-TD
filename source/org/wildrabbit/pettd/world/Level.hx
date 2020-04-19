package org.wildrabbit.pettd.world;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.addons.editors.tiled.TiledImageLayer;
import flixel.addons.editors.tiled.TiledImageTile;
import flixel.addons.editors.tiled.TiledLayer.TiledLayerType;
import flixel.addons.editors.tiled.TiledMap;
import flixel.addons.editors.tiled.TiledObject;
import flixel.addons.editors.tiled.TiledObjectLayer;
import flixel.addons.editors.tiled.TiledPropertySet;
import flixel.addons.editors.tiled.TiledTile;
import flixel.addons.editors.tiled.TiledTileLayer;
import flixel.addons.editors.tiled.TiledTileSet;
import flixel.addons.editors.tiled.TiledTilePropertySet;
import flixel.group.FlxGroup;
import flixel.math.FlxPoint;
import flixel.math.FlxRandom;
import flixel.math.FlxVector;
import flixel.tile.FlxTilemap;
import flixel.addons.tile.FlxTilemapExt;
import flixel.addons.tile.FlxTileSpecial;
import haxe.ds.Map;
import haxe.io.Path;
import org.wildrabbit.pettd.PlayState;
import org.wildrabbit.pettd.Turret;
import org.wildrabbit.pettd.world.LevelDataTable.FloatVec2;
import org.wildrabbit.pettd.world.LevelDataTable.IntVec2;

/**
 * ...
 * @author wildrabbit
 */
class Level extends TiledMap
{
	
	inline static var PATH_TILESET = "assets/images/";
	
	public var foreground:FlxGroup; // TODO
	public var background:FlxGroup;
	
	public var waveSpawns:Map<String,IntVec2>;
	
	public var playerCoords:IntVec2;
	
	var parentState:PlayState;
	
	public var playerPos(get, null):FloatVec2;
	
	public var navigationMap:FlxTilemap;
	
	function get_playerPos() return posFromCoords(playerCoords);
	
	public function getSpawnPos(id:String):FloatVec2
	{
		return posFromCoords(waveSpawns[id]);
	}
	
	public function getRandomSpawnPos():FloatVec2
	{
		var keyList:Array<String> = new Array<String>();
		var keyIter:Iterator<String> = waveSpawns.keys();
		while (keyIter.hasNext())
		{
			keyList.push(keyIter.next());
		}
		
		var flxRandom:FlxRandom = new FlxRandom();
		var key:String = flxRandom.getObject(keyList);
		
		return posFromCoords(waveSpawns[key]);
	}
	
	public function coordsFromPos(pos:FloatVec2):IntVec2
	{
		var coords:IntVec2 = {
			x:0,
			y:0
		};
		coords.x = Math.floor(pos.x / tileWidth);
		coords.y = Math.floor(pos.y / tileHeight);
		return coords;
	}
	
	public function posFromCoords(coords:IntVec2):FloatVec2
	{
		var pos:FloatVec2 = { x:0, y:0};
		pos.x = coords.x * tileWidth;
		pos.y = coords.y * tileHeight;
		return pos;
	}
	
	
	public function new(tiledLevel:FlxTiledMapAsset, state:PlayState) 
	{
		super(tiledLevel);
		
		foreground = new FlxGroup();
		background = new FlxGroup();
		
		
		FlxG.camera.setScrollBoundsRect(0, 0, fullWidth, fullHeight, true);
		
		// load images
		
		// load objects
		
		var groupMap:Map<String,FlxGroup> = ["background" => background, "foreground" => foreground];
		
		
		for (layer in layers)
		{
			if (layer.type == TiledLayerType.TILE)
			{
				handleTileLayer(cast layer, groupMap);
			}
			else if (layer.type == TiledLayerType.OBJECT)
			{
				handleObjectLayer(cast layer);
			}
		}
	}
	
	private function handleObjectLayer(tileLayer:TiledObjectLayer):Void
	{
		waveSpawns = new Map<String, IntVec2>();
		for (obj in tileLayer.objects)
		{
			if (obj.type == "pet_position")
			{
				playerCoords = coordsFromPos({"x": obj.x, "y": obj.y});
			}
			else if (obj.type == "mob_spawn")
			{
				var spawnPos:IntVec2 = coordsFromPos({"x": obj.x, "y": obj.y});
				waveSpawns[obj.name] = spawnPos;
			}
		}
	}
	
	private function handleTileLayer(tileLayer:TiledTileLayer , groupMap:Map<String,FlxGroup>):Void
	{
		var tilesheetName:String = tileLayer.properties.get("tileset");
		if (tilesheetName == null)
		{
			throw 'tileset property not defined for the ${tileLayer.name} layer. Please define it';
		}
		
		var tileset :TiledTileSet = null;
		for (ts in tilesets)
		{
			if (ts.name == tilesheetName)
			{
				tileset = ts;
				break;
			}
		}
		
		if (tileset == null)
		{
			throw 'tileset ${tilesheetName} not found.';
		}
		
		var tileArray:Array<Int> = tileLayer.tileArray;
		
		var imgPath = new Path(tileset.imageSource);
		var processed = '${PATH_TILESET}${imgPath.file}.${imgPath.ext}';
		var tilemap = new FlxTilemap();
		tilemap.loadMapFromArray(tileArray, width, height, processed, tileset.tileWidth, tileset.tileHeight, OFF, tileset.firstGID, 1, 1);
		
		var hasNavigationInfo:Bool = tileLayer.properties.get("path-info") == "true";
		if (hasNavigationInfo)
		{
			navigationMap = tilemap;
			var idx:Int = 0;
			while(idx < tileset.tileTypes.length)
			{
				var tileGid:Int = tileset.toGid(idx);
					
				if (tileset.tileTypes[idx] == "road")
				{
					navigationMap.setTileProperties(tileGid, FlxObject.NONE);
				}
				else
				{
					navigationMap.setTileProperties(tileGid, FlxObject.ANY);
				}
				idx++;
			}
		}

		
		if (groupMap.exists(tileLayer.name))
		{
			groupMap[tileLayer.name].add(tilemap);
		}		
	}
	public function destroy():Void
	{
		for (bgObject in background)
		{
			bgObject.destroy();			
		}
		background.clear();
		
		for (fgObject in foreground)
		{
			fgObject.destroy();
		}
		foreground.clear();
	}
	
	public function isValidTurretRect(pos:IntVec2, width:Int, height:Int, turrets:FlxTypedGroup<Turret>):Bool
	{
		var col:Int = pos.x;
		var row:Int = pos.y;
		var freeSpace:Bool = true;
		while (freeSpace && row < this.height && row < pos.y + height)
		{
			col = pos.x;
			while (freeSpace && col < this.width && col < pos.x + width)
			{
				var tileValue:Int = navigationMap.getTile(col, row);
				var point:FlxPoint = FlxVector.get(col, row);
				var collisions:Int = navigationMap.getTileCollisions(tileValue);
				if (collisions == FlxObject.NONE)
				{
					freeSpace = false;
					break;
				}				
				
						
				for (turret in turrets)
				{
					if (turret.overlapsPoint(point))
					{
						freeSpace = false;
						break;
					}
				}
				col++;
				point.put();
			}
			row++;
		}
		
		if (!freeSpace)
		{
			return false;
		}
		
		// TODO: Check close to road
		return true;
	}	
}