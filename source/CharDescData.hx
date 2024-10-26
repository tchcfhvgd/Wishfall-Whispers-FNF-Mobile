package;

#if MODS_ALLOWED
import sys.io.File;
import sys.FileSystem;
#else
import openfl.utils.Assets;
#end
import haxe.Json;
import haxe.format.JsonParser;
import Song;

using StringTools;

typedef CharDescFile = {
	var charName:String;
	var desc:String;
	var color:String;
}

class CharDescData {
	public static var forceNextDirectory:String = null;
	public static function loadDirectory(theCharName:String) {
		var laCharName:String = '';
		// if(SONG.stage != null) {
		// 	stage = SONG.stage;
		// } else if(SONG.song != null) {
		// 	switch (SONG.song.toLowerCase().replace(' ', '-'))
		// 	{
		// 		case 'spookeez' | 'south' | 'monster':
		// 			stage = 'spooky';
		// 		case 'pico' | 'blammed' | 'philly' | 'philly-nice':
		// 			stage = 'philly';
		// 		case 'milf' | 'satin-panties' | 'high':
		// 			stage = 'limo';
		// 		case 'cocoa' | 'eggnog':
		// 			stage = 'mall';
		// 		case 'winter-horrorland':
		// 			stage = 'mallEvil';
		// 		case 'senpai' | 'roses':
		// 			stage = 'school';
		// 		case 'thorns':
		// 			stage = 'schoolEvil';
		// 		default:
		// 			stage = 'stage';
		// 	}
		// } else {
		// 	stage = 'stage';
		// }

		var charDescFile:CharDescFile = getCharDescFile(theCharName);
		if(theCharName == null) { //preventing crashes
			//forceNextDirectory = '';
		} else {
			//forceNextDirectory = charDescFile.directory;
		}
	}

	public static function getCharDescFile(theCharName:String):CharDescFile {
		var rawJson:String = null;
		var path:String = Paths.getPreloadPath('descriptions/' + theCharName + '.json');
		trace(theCharName);
		trace(path);

		#if MODS_ALLOWED
		var modPath:String = Paths.modFolders('descriptions/' + theCharName + '.json');
		if(FileSystem.exists(modPath)) {
			rawJson = File.getContent(modPath);
		} else if(FileSystem.exists(path)) {
			rawJson = File.getContent(path);
		}
		#else
		if(Assets.exists(path)) {
			rawJson = Assets.getText(path);
		}
		#end
		else
		{
			return null;
		}
		return cast Json.parse(rawJson);
	}
}