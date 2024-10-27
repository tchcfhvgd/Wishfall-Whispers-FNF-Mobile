package;

#if MODS_ALLOWED
import sys.io.File;
import sys.FileSystem;
#end
import lime.utils.Assets;
import openfl.utils.Assets as OpenFlAssets;
import haxe.Json;
import haxe.format.JsonParser;

using StringTools;

typedef WeekFile =
{
	// JSON variables
	var songs:Array<Dynamic>;
	var weekCharacters:Array<String>;
	var weekBackground:String;
	var weekBefore:String;
	var storyName:String;
	var weekDesc:String;
	var weekName:String;
	var freeplayColor:Array<Int>;
	var startUnlocked:Bool;
	var hideStoryMode:Bool;
	var hideFreeplay:Bool;
	var weekColor:Array<Int>;
	var hasLucid:Bool;
}

class WeekData {
	public static var weeksLoaded:Map<String, WeekData> = new Map<String, WeekData>();
	public static var weeksBLoaded:Map<String, WeekData> = new Map<String, WeekData>();
	public static var weeksList:Array<String> = [];
	public static var weeksBList:Array<String> = [];
	public var folder:String = '';
	
	// JSON variables
	public var songs:Array<Dynamic>;
	public var weekCharacters:Array<String>;
	public var weekBackground:String;
	public var weekBefore:String;
	public var storyName:String;
	public var weekDesc:String;
	public var weekName:String;
	public var freeplayColor:Array<Int>;
	public var startUnlocked:Bool;
	public var hideStoryMode:Bool;
	public var hideFreeplay:Bool;
	public var weekColor:Array<Int>;
	public var hasLucid:Bool;

	public static function createWeekFile():WeekFile {
		trace('testing html5');
		var weekFile:WeekFile = {
			songs: [["Bopeebo", "dad", [146, 113, 253]], ["Fresh", "dad", [146, 113, 253]], ["Dad Battle", "dad", [146, 113, 253]], '', ''],
			weekCharacters: ['dad', 'bf', 'gf'],
			weekBackground: 'stage',
			weekBefore: 'tutorial',
			storyName: 'Your New Week',
			weekDesc: 'Week Description',
			weekName: 'Custom Week',
			freeplayColor: [146, 113, 253],
			startUnlocked: true,
			hideStoryMode: false,
			hideFreeplay: false,
			weekColor: [146, 113, 253],
			hasLucid: false,
		};
		return weekFile;
	}

	// HELP: Is there any way to convert a WeekFile to WeekData without having to put all variables there manually? I'm kind of a noob in haxe lmao
	public function new(weekFile:WeekFile) {
		songs = weekFile.songs;
		weekCharacters = weekFile.weekCharacters;
		trace('testing html5');
		weekBackground = weekFile.weekBackground;
		weekBefore = weekFile.weekBefore;
		storyName = weekFile.storyName;
		weekDesc = weekFile.weekDesc;
		weekName = weekFile.weekName;
		freeplayColor = weekFile.freeplayColor;
		startUnlocked = weekFile.startUnlocked;
		hideStoryMode = weekFile.hideStoryMode;
		hideFreeplay = weekFile.hideFreeplay;
		weekColor = weekFile.weekColor;
		hasLucid = weekFile.hasLucid;
	}

	public static function reloadWeekFiles(isStoryMode:Null<Bool> = false)
	{
		trace('testing html5');
		weeksList = [];
		weeksLoaded.clear();
		var directories:Array<String> = [Paths.getPreloadPath()];
		var originalLength:Int = directories.length;

		var sexList:Array<String> = CoolUtil.coolTextFile(Paths.getPreloadPath('weeks/weekList.txt'));
		
		for (i in 0...sexList.length) {
			for (j in 0...directories.length) {
				var fileToCheck:String = directories[j] + 'weeks/' + sexList[i] + '.json';
				if(!weeksLoaded.exists(sexList[i])) {
					var week:WeekFile = getWeekFile(fileToCheck);
					if(week != null) {
						var weekFile:WeekData = new WeekData(week);

						if(weekFile != null && (isStoryMode == null || (isStoryMode && !weekFile.hideStoryMode) || (!isStoryMode && !weekFile.hideFreeplay))) {
							weeksLoaded.set(sexList[i], weekFile);
							weeksList.push(sexList[i]);
						}
					}
				}
			}

		}

	}

	public static function reloadWeekBFiles(isStoryMode:Null<Bool> = false)
		{
			trace('testing html5');
			weeksBList = [];
			weeksBLoaded.clear();
			trace('testing html5');
			var directories:Array<String> = [Paths.getPreloadPath()];
			var originalLength:Int = directories.length;
			trace('testing html5');
			var sexList:Array<String> = CoolUtil.coolTextFile(Paths.getPreloadPath('weeksb/weekBList.txt'));
			for (i in 0...sexList.length) {
				trace(sexList.length);
				for (j in 0...directories.length) {
					trace(sexList.length);
					var fileToCheck:String = directories[j] + 'weeksb/' + sexList[i] + '.json';
					trace(sexList[i]);
					trace(fileToCheck);
					
					if(!weeksBLoaded.exists(sexList[i])) {
						trace(sexList[i]);
						var week:WeekFile = getWeekBFile(fileToCheck);
						if(week != null) {
							var weekFile:WeekData = new WeekData(week);
							trace(week);

							trace(week);
	
							if(weekFile != null && (isStoryMode == null || (isStoryMode && !weekFile.hideStoryMode) || (!isStoryMode && !weekFile.hideFreeplay))) {
								weeksBLoaded.set(sexList[i], weekFile);
								weeksBList.push(sexList[i]);
							}
						}
					}
				}
	
			}
			trace('testing html5');
		}

	private static function getWeekFile(path:String):WeekFile {
		var rawJson:String = null;
		if(OpenFlAssets.exists(path)) {
			rawJson = Assets.getText(path);
			
		}

		if(rawJson != null && rawJson.length > 0) {
			return cast Json.parse(rawJson);
		}
		return null;
	}

	private static function getWeekBFile(path:String):WeekFile {
		var rawJson:String = null;
		if(OpenFlAssets.exists(path)) {
			rawJson = Assets.getText(path);
			
		}

		if(rawJson != null && rawJson.length > 0) {
			return cast Json.parse(rawJson);
			trace('it works');
		}
		else trace('doesnt work');

		return null;
	}

	//   FUNCTIONS YOU WILL PROBABLY NEVER NEED TO USE

	//To use on PlayState.hx or Highscore stuff
	public static function getWeekFileName():String {
		
		if (PlayState.isCampaignB == true)
			{
				return weeksBList[PlayState.storyWeek];
			}
		else
			{
				return weeksList[PlayState.storyWeek];
			}
	}

	//Used on LoadingState, nothing really too relevant
	public static function getCurrentWeek():WeekData {
		if (PlayState.isCampaignB == true)
		{
			return weeksBLoaded.get(weeksBList[PlayState.storyWeek]);
		}
		else
			{
				return weeksLoaded.get(weeksList[PlayState.storyWeek]);
			}
		
	}

	public static function setDirectoryFromWeek(?data:WeekData = null) {
		Paths.currentModDirectory = '';
		if(data != null && data.folder != null && data.folder.length > 0) {
			Paths.currentModDirectory = data.folder;
		}
	}
}
