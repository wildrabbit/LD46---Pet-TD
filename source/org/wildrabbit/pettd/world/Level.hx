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
import haxe.io.Path;
import org.wildrabbit.pettd.PlayState;

/**
 * ...
 * @author wildrabbit
 */
class Level extends TiledMap
{
	
	inline static var PATH_TILESET = "assets/images/";
	
	public var foreground:FlxGroup; // TODO
	public var background:FlxGroup;
	
	var parentState:PlayState;
	
	
	public function new(tiledLevel:FlxTiledMapAsset, state:PlayState) 
	{
		super(tiledLevel);
		
		foreground = new FlxGroup();

		background = new FlxGroup();
		
		FlxG.camera.setScrollBoundsRect(0, 0, fullWidth, fullHeight, true);
		
		// load images
		
		// load objects
		
	
		
		for (layer in layers)
		{
			if (layer.type != TiledLayerType.TILE)
			{
				continue;
			}
			var tileLayer:TiledTileLayer = cast layer;
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
			background.add(tilemap);
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