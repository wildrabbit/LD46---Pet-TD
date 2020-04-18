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
import flixel.addons.editors.tiled.TiledTileLayer;
import flixel.addons.editors.tiled.TiledTileSet;
import flixel.addons.editors.tiled.TiledTilePropertySet;
import flixel.group.FlxGroup;
import flixel.tile.FlxTilemap;
import flixel.addons.tile.FlxTilemapExt;
import flixel.addons.tile.FlxTileSpecial;
import haxe.ds.Map;
import haxe.io.Path;
import org.wildrabbit.pettd.PlayState;
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
	
	public var PlayerPos(get, null):FloatVec2;
	
	function get_PlayerPos() return PosFromCoords(playerCoords);
	
	public function CoordsFromPos(pos:FloatVec2):IntVec2
	{
		var coords:IntVec2 = {
			x:0,
			y:0
		};
		coords.x = Math.round(pos.x / tileWidth);
		coords.y = Math.round(pos.y / tileHeight);
		return coords;
	}
	
	public function PosFromCoords(coords:IntVec2):FloatVec2
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
				playerCoords = CoordsFromPos({"x": obj.x, "y": obj.y});
			}
			else if (obj.type == "mob_spawn")
			{
				var spawnPos:IntVec2 = {"x": obj.x, "y": obj.y};
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

		var imgPath = new Path(tileset.imageSource);
		var processed = '${PATH_TILESET}${imgPath.file}.${imgPath.ext}';
		var tilemap = new FlxTilemap();
		tilemap.loadMapFromArray(tileLayer.tileArray, width, height, processed, tileset.tileWidth, tileset.tileHeight, OFF, tileset.firstGID, 1, 1);
		
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
	
}