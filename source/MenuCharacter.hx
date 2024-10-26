package;

import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
#if MODS_ALLOWED
import sys.io.File;
import sys.FileSystem;
#end
import openfl.utils.Assets;
import haxe.Json;
import haxe.format.JsonParser;
import MusicBeatState;

typedef MenuCharacterFile = {
	var image:String;
	var scale:Float;
	var position:Array<Int>;
	var idle_anim:String;
	var confirm_anim:String;
}

// typedef MenuCharacterFile = {
// 	var idle_anim:String;
// 	//var danceLeft:String;
//  	var confirm_anim:String;
// 	var image:String;
// 	var scale:Float;
// 	var position:Array<Int>;
// }

class MenuCharacter extends FlxSprite
{
	public var character:String;
	private static var DEFAULT_CHARACTER:String = 'bf';

	public function new(x:Float, character:String = 'bf', ?storyMenu:Bool)
	{
		super(x);

		if(storyMenu)
			changeCharacter(character, storyMenu);
		else
			changeCharacter(character);
	}

	public function changeCharacter(?character:String = 'bf', ?storyMenu:Bool) {
		if(character == null) character = '';
		if(character == this.character) return;

		this.character = character;
		antialiasing = ClientPrefs.globalAntialiasing;
		visible = true;

		var dontPlayAnim:Bool = false;
		scale.set(1, 1);
		updateHitbox();

		switch(character) {
			case '':
				visible = false;
				dontPlayAnim = true;
			default:
				var characterPath:String;
				if(MusicBeatState.glutoMode)
					characterPath = 'images/menucharacters/gluto.json';
				else
					characterPath = 'images/menucharacters/' + character + '.json';
				//var characterPath:String = 'images/menucharacters/' + character + '.json';
				var rawJson = null;

				// #if MODS_ALLOWED
				// var path:String = Paths.modFolders(characterPath);
				// if (!FileSystem.exists(path)) {
				// 	path = Paths.getPreloadPath(characterPath);
				// }
				// else {trace("mod path was found");}

				// if(!FileSystem.exists(path)) {
				// 	path = Paths.getPreloadPath('images/menucharacters/' + DEFAULT_CHARACTER + '.json');
				// }
				// rawJson = File.getContent(path);

				// #else
				var path:String = Paths.getPreloadPath(characterPath);
				if(!Assets.exists(path)) {
					path = Paths.getPreloadPath('images/menucharacters/' + 'gina' + '.json');
					trace("doesnt exist");
				}
				rawJson = Assets.getText(path);
				//#end
				
				var charFile:MenuCharacterFile = cast Json.parse(rawJson);
				trace(charFile);
				trace(rawJson);
				frames = Paths.getSparrowAtlas('characters/' + charFile.image);
				//trace(frames);
				if(MusicBeatState.glutoMode)
					animation.addByPrefix('idle_anim', charFile.idle_anim, 40, true);
				else
					animation.addByPrefix('idle_anim', charFile.idle_anim, 24, true);
				//animation.addByPrefix('danceLeft', charFile.danceLeft, 24);
				animation.addByPrefix('confirm', charFile.confirm_anim, 24, false);

				if(charFile.scale != 1) {
					scale.set(charFile.scale, charFile.scale);
					updateHitbox();
				}

				if(MusicBeatState.glutoMode && storyMenu)
					{
						scale.set(1.4, 1.4);
						updateHitbox();
					}

				offset.set(charFile.position[0], charFile.position[1]);
				animation.play('idle_anim');
				trace(charFile);
				trace(charFile.idle_anim);
				animation.play('idle_anim');
				
				// if(animation.curAnim.name == 'idle_anim' && animation.curAnim.finished)
				// 	{
				// 		animation.play('danceLeft');
				// 	}
				// if(animation.curAnim.name == 'danceLeft' && animation.curAnim.finished)
				// 	{
				// 		animation.play('idle_anim');
				// 	}

				// var json:CharacterFile = cast Json.parse(rawJson);
				// if(Assets.exists(Paths.getPath('images/' + json.image + '.txt', TEXT))) {
				// 	frames = Paths.getPackerAtlas(json.image);
				// } else {
				// 	frames = Paths.getSparrowAtlas(json.image);
				// }

				
		}
	}
}
