package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.animation.FlxBaseAnimation;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.tweens.FlxTween;
import flixel.util.FlxSort;
import Section.SwagSection;
#if MODS_ALLOWED
import sys.io.File;
import sys.FileSystem;
#end
import openfl.utils.Assets;
import haxe.Json;
import haxe.format.JsonParser;
import Song.SwagSong;

using StringTools;

typedef CharacterFile = {
	var animations:Array<AnimArray>;
	var image:String;
	var scale:Float;
	var sing_duration:Float;
	var healthicon:String;

	var position:Array<Float>;
	var camera_position:Array<Float>;

	var flip_x:Bool;
	var dynamicFPS:Bool;
	var no_antialiasing:Bool;
	var healthbar_colors:Array<Int>;
}

typedef AnimArray = {
	var anim:String;
	var name:String;
	var fps:Int;
	var loop:Bool;
	var indices:Array<Int>;
	var offsets:Array<Int>;
}

class Character extends FlxSprite
{
	public var animOffsets:Map<String, Array<Dynamic>>;
	public var debugMode:Bool = false;

	public var isPlayer:Bool = false;
	public var curCharacter:String = DEFAULT_CHARACTER;

	public var colorTween:FlxTween;
	public var holdTimer:Float = 0;
	public var heyTimer:Float = 0;
	public var specialAnim:Bool = false;
	public var animationNotes:Array<Dynamic> = [];
	public var stunned:Bool = false;
	public var singDuration:Float = 4; //Multiplier of how long a character holds the sing pose
	public var idleSuffix:String = '';
	public var danceIdle:Bool = false; //Character use "danceLeft" and "danceRight" instead of "idle"

	public var healthIcon:String = 'face';
	public var animationsArray:Array<AnimArray> = [];

	public var positionArray:Array<Float> = [0, 0];
	public var cameraPosition:Array<Float> = [0, 0];

	//Used on Character Editor
	public var imageFile:String = '';
	public var jsonScale:Float = 1;
	public var noAntialiasing:Bool = false;
	public var originalFlipX:Bool = false;
	public var originalDynamicFPS:Bool = false;
	public var healthColorArray:Array<Int> = [255, 0, 0];
	public var alreadyLoaded:Bool = true; //Used by "Change Character" event

	public static var DEFAULT_CHARACTER:String = 'lilac'; //In case a character is missing, it will use BF on its place

	public var returning:Bool = false;
	public var theAnimName:String;
	public var returned:Bool = true;
	public var holdAnim:Bool = false;
	public var sustaining:Bool = false;
	
	public var dynamicFPS:Bool = false;

	public function new(x:Float, y:Float, ?character:String = 'bf', ?isPlayer:Bool = false, ?daBpm:Float = 24)
	{
		theAnimName = null;
		var _song:SwagSong = PlayState.SONG;
		//trace(_song);
		super(x, y);

		#if (haxe >= "4.0.0")
		animOffsets = new Map();
		#else
		animOffsets = new Map<String, Array<Dynamic>>();
		#end
		curCharacter = character;
		this.isPlayer = isPlayer;
		antialiasing = ClientPrefs.globalAntialiasing;
		returning = false;
		returned = true;

		var library:String = null;
		switch (curCharacter)
		{
			//case 'your character name in case you want to hardcode him instead':

			default:
				var characterPath:String = 'characters/' + curCharacter + '.json';
				#if MODS_ALLOWED
				var path:String = Paths.modFolders(characterPath);
				if (!FileSystem.exists(path)) {
					path = Paths.getPreloadPath(characterPath);
				}

				if (!FileSystem.exists(path))
				#else
				var path:String = Paths.getPreloadPath(characterPath);
				if (!Assets.exists(path))
				#end
				{
					path = Paths.getPreloadPath('characters/' + DEFAULT_CHARACTER + '.json'); //If a character couldn't be found, change him to BF just to prevent a crash
				}

				#if MODS_ALLOWED
				var rawJson = File.getContent(path);
				#else
				var rawJson = Assets.getText(path);
				#end

				var json:CharacterFile = cast Json.parse(rawJson);
				if(Assets.exists(Paths.getPath('images/' + json.image + '.txt', TEXT))) {
					frames = Paths.getPackerAtlas(json.image);
				} else {
					frames = Paths.getSparrowAtlas(json.image);
				}
				imageFile = json.image;

				if(json.scale != 1) {
					jsonScale = json.scale;
					setGraphicSize(Std.int(width * jsonScale));
					updateHitbox();
				}

				positionArray = json.position;
				cameraPosition = json.camera_position;

				healthIcon = json.healthicon;
				singDuration = json.sing_duration;
				flipX = !!json.flip_x;
				dynamicFPS = json.dynamicFPS;
				if(json.no_antialiasing) {
					antialiasing = false;
					noAntialiasing = true;
				}

				if(json.healthbar_colors != null && json.healthbar_colors.length > 2)
					healthColorArray = json.healthbar_colors;

				antialiasing = !noAntialiasing;
				if(!ClientPrefs.globalAntialiasing) antialiasing = false;

				animationsArray = json.animations;
				if(animationsArray != null && animationsArray.length > 0) {
					for (anim in animationsArray) {
						var animAnim:String = '' + anim.anim;
						var animName:String = '' + anim.name;
						var animFps:Int;
						var animSpeedMultiplier:Float = 1;
						
						// if(_song.animSpeedMultiplier == 1 || _song.animSpeedMultiplier == 0.5)
						// 	{animSpeedMultiplier = _song.animSpeedMultiplier;}
						// 	else {animSpeedMultiplier = 1;}
						
							//trace(_song.song);
						//var animIsSmoothAnim:Bool = anim.isSmoothAnim;
					//if(animIsSmoothAnim != null && animIsSmoothAnim)
					if(dynamicFPS)
						{
							if(_song != null)
								{	
									if(_song.animSpeedMultiplier > 0)
									animSpeedMultiplier = _song.animSpeedMultiplier;
									else animSpeedMultiplier = 0.5;
									trace(_song.bpm);
									trace("omg");
									animFps = Std.int(anim.fps * (animSpeedMultiplier * _song.bpm/(60)));	
									trace('animation frames:' + animFps);
								}
								else{
									trace('animation frames:');
									animFps = Std.int(anim.fps * (animSpeedMultiplier * 100/(60)));	
									trace('animation frames:' + animFps);
								}
						}
					else
						{
							animFps = anim.fps;
						}
						

					//var animFps:Int = 30;
						var animLoop:Bool = !!anim.loop; //Bruh
						var animIndices:Array<Int> = anim.indices;
						if(animIndices != null && animIndices.length > 0) {
							animation.addByIndices(animAnim, animName, animIndices, "", animFps, animLoop);

							if (animAnim.contains("sing") && !animAnim.contains("miss") && !animAnim.contains("Return"))
							{
								animation.addByIndices(animAnim + "Sustain", animName, [7,7,6,6,5,4,3,4,5,6], "", animFps, true);
							}

						} else {
							animation.addByPrefix(animAnim, animName, animFps, animLoop);
						}

					

						if(anim.offsets != null && anim.offsets.length > 1) {
							addOffset(anim.anim, anim.offsets[0], anim.offsets[1]);
						}
						 if (animAnim.contains("sing") && !animAnim.contains("miss") && !animAnim.contains("Return"))
							{
								addOffset(anim.anim + "Sustain", anim.offsets[0], anim.offsets[1]);
							}
					}
				} else {
					quickAnimAdd('idle', 'BF idle dance');
				}
				//trace('Loaded file to character ' + curCharacter);
		}
		originalFlipX = flipX;
		originalDynamicFPS = dynamicFPS;

		recalculateDanceIdle();
		dance();

		if (isPlayer)
		{
			flipX = !flipX;

			/*// Doesn't flip for BF, since his are already in the right place???
			if (!curCharacter.startsWith('bf'))
			{
				// var animArray
				if(animation.getByName('singLEFT') != null && animation.getByName('singRIGHT') != null)
				{
					var oldRight = animation.getByName('singRIGHT').frames;
					animation.getByName('singRIGHT').frames = animation.getByName('singLEFT').frames;
					animation.getByName('singLEFT').frames = oldRight;
				}

				// IF THEY HAVE MISS ANIMATIONS??
				if (animation.getByName('singLEFTmiss') != null && animation.getByName('singRIGHTmiss') != null)
				{
					var oldMiss = animation.getByName('singRIGHTmiss').frames;
					animation.getByName('singRIGHTmiss').frames = animation.getByName('singLEFTmiss').frames;
					animation.getByName('singLEFTmiss').frames = oldMiss;
				}
			}*/
		}
	}

	override function update(elapsed:Float)
	{

	
		if(theAnimName != null && theAnimName.contains("sing") && !theAnimName.contains("miss") && !theAnimName.contains('Sustain'))
			{
				returned = false;

				//trace("this sucks assssssssssssssssssssssssssss");
				if(animation.curAnim.finished && animation.curAnim.name.startsWith('sing') && !animation.curAnim.name.endsWith('Return'))
					{
						playAnim(theAnimName + "Return");
						trace(theAnimName + "Return");			
						theAnimName = null;
						returning = true;
					}
				
			}
		if ((returning == true))
				{	
					//returned = false;

					//trace(animation.curAnim.name + "PLESE WORK GODDAMN ITT AAAAAAAAAAAAAAAAAAAAAAAAA");

					if(animation.curAnim.finished)
						{
							returning = false;			
							returned = true;
							danced = false;
							//playAnim("noAnim");
							//animation.curAnim.name = "noAnim";
							//trace(animation.curAnim.name + " IS THE ANIM RN");
						}
				}

		if(!debugMode && animation.curAnim != null)
		{
			if(heyTimer > 0)
			{
				heyTimer -= elapsed;
				if(heyTimer <= 0)
				{
					if(specialAnim && animation.curAnim.name == 'hey' || animation.curAnim.name == 'cheer')
					{
						specialAnim = false;
						dance();
					}
					heyTimer = 0;
				}
			} else if(specialAnim && animation.curAnim.finished)
			{
				specialAnim = false;
				dance();
			}

			if (!isPlayer)
			{
				if (animation.curAnim.name.startsWith('sing'))
				{
					holdTimer += elapsed;
				}

				if (holdTimer >= Conductor.stepCrochet * 0.001 * singDuration && (animation.curAnim.finished || !animation.curAnim.name.startsWith('sing')))
				{
					
					//dance();
					holdTimer = 0;
				}
			}

			if(animation.curAnim.finished && animation.getByName(animation.curAnim.name + '-loop') != null)
			{
				playAnim(animation.curAnim.name + '-loop');
			}
		}
		super.update(elapsed);
	}

	public var danced:Bool = true;

	/**
	 * FOR GF DANCING SHIT
	 */

	public function canIdle(?boyfriend:Boyfriend, ?gfOrDad:Character):Bool
		{
			var canIdle:Bool;
			if(boyfriend != null)
				{
					if ((boyfriend.animation.curAnim.name != null && boyfriend.returned && boyfriend.returning == false) || ((boyfriend.returned && boyfriend.returning == false)))
					{
						canIdle = true;
					}
					else {canIdle = false;}
					//trace(boyfriend.returned);
					return canIdle;
					
					
				}
			else if (gfOrDad != null)
				{
					if ((gfOrDad.animation.curAnim.name != null && gfOrDad.returned && gfOrDad.returning == false) || ((gfOrDad.returned && gfOrDad.returning == false)))
					{
						canIdle = true;
					}
					else {canIdle = false;}
					return canIdle;
				}
			else {return false;}
			
			
		}

	public function dance()
	{
		//returned = true;
		//if(!returning)
		//	{	
				if (!debugMode && !specialAnim && returned == true)
				{
					if(danceIdle)
					{
						
						danced = !danced;
						//trace(curCharacter + "_" + danced);
						if (danced)
							{playAnim('danceRight' + idleSuffix);
						trace(curCharacter + "_" + "danceRight");}
						else
							{playAnim('danceLeft' + idleSuffix);
						//curCharacter + "_" + "danceLeft");
					}
					}
					else if(animation.getByName('idle' + idleSuffix) != null) {
							playAnim('idle' + idleSuffix);
					}
				}
			//}
	}

	public function playAnim(AnimName:String, Force:Bool = false, Reversed:Bool = false, Frame:Int = 0):Void
	{
		specialAnim = false;
		//var animFps:Int = anim.fps;
		//animation.fps = 2;
		animation.play(AnimName, Force, Reversed, Frame);

		var daOffset = animOffsets.get(AnimName);
		if (animOffsets.exists(AnimName))
		{
			offset.set(daOffset[0], daOffset[1]);
		}
		else
			offset.set(0, 0);

		

		if(AnimName.contains("sing") && !AnimName.contains("Return") && !AnimName.contains("miss") && !AnimName.contains("Sustain"))
			{
				returning = false;
				returned = false;
				danced = false;
				theAnimName = AnimName;
				//canIdle = false;
				//trace(AnimName + " is the AnimName");
			}

			if(!AnimName.contains("dance"))
				{
					//canIdle = false;
					//trace(AnimName + " is the AnimName");
				}

			

		if (curCharacter.startsWith('gf'))
		{
			if (AnimName == 'singLEFT')
			{
				//danced = true;
			}
			else if (AnimName == 'singRIGHT')
			{
				//danced = false;
			}

			if (AnimName == 'singUP' || AnimName == 'singDOWN')
			{
				//danced = !danced;
			}
		}
	}

	public function recalculateDanceIdle() {
		danceIdle = (animation.getByName('danceLeft' + idleSuffix) != null && animation.getByName('danceRight' + idleSuffix) != null);
	}

	public function addOffset(name:String, x:Float = 0, y:Float = 0)
	{
		animOffsets[name] = [x, y];
	}

	public function quickAnimAdd(name:String, anim:String)
	{
		animation.addByPrefix(name, anim, 24, false);
	}
}
