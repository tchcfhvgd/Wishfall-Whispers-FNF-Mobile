package;

import Conductor.BPMChangeEvent;
import flixel.FlxG;
import flixel.addons.ui.FlxUIState;
import flixel.math.FlxRect;
import flixel.util.FlxTimer;
import flixel.addons.transition.FlxTransitionableState;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxGradient;
import flixel.FlxSubState;
import flixel.FlxSprite;
import flixel.FlxCamera;
import openfl.utils.Assets as OpenFlAssets;

#if sys
import sys.FileSystem;
#end
import CustomFadeTransition;

class CustomWipeTransition extends MusicBeatSubstate {
	public static var finishCallback:Void->Void;
	var isTransIn:Bool = false;
	static var leVideo:FlxVideo = null;

	public function new() {
		super();

		// if(isTransIn) {
		// 	startVideoWipe('wipeIn');
		// } else {
		// 	startVideoWipe('wipeOut');
		// }


		//this.isTransIn = isTransIn;

		// if(isTransIn) {
		// 	startVideoWipe('wipeIn');
		// } else {
		// 	startVideoWipe('wipeOut');
		// }

	}

	public function startVideoWipe(name:String):Void {


		if(!ClientPrefs.lowQuality)
		{
			#if VIDEOS_ALLOWED
			var foundFile:Bool = false;
			var fileName:String = #if MODS_ALLOWED Paths.modFolders('videos/' + name + '.' + Paths.VIDEO_EXT); #else ''; #end
			#if sys
			if(FileSystem.exists(fileName)) {
				foundFile = true;
			}
			#end

			if(!foundFile) {
				
				fileName = Paths.video(name);
				#if sys
				if(FileSystem.exists(fileName)) {
				#else
				if(OpenFlAssets.exists(fileName)) {
				#end
					foundFile = true;
				}
			}

			if(foundFile) {


				
				//inCutscene = true;
				// var bg2 = new FlxSprite(-FlxG.width, -FlxG.height).makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.BLACK);
				// bg2.scrollFactor.set();
				// bg2.cameras = [camGame];
				// add(bg2);
				
				// if(name == 'wipeOut')
				// 	{	
				// 		new FlxTimer().start(0.1, function(tmr:FlxTimer)
				// 	{
				// 		var blackBarThingie:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, 56, FlxColor.BLACK);
				// 		add(blackBarThingie);
				// 	});
				// 		return;
				// 	}
						#if desktop
				if (leVideo != null) {
					leVideo.skipVideo();
				}
				#end
				(leVideo = new FlxVideo(fileName)).finishCallback = function() 
				{
					leVideo = null;
					if(name == "wipeOut")
						{
							trace("BOOTIE BOY");
							CustomFadeTransition.screenBlack();
							
						}
				}
				
				return;
			} else {
				
				FlxG.log.warn('Couldnt find video file: ' + fileName);
			}
			#end

		}

		// if(endingSong) {
		// 	endSong();
		// } else {
		// 	startCountdown();
		// }
	}

	override function update(elapsed:Float) {

	}

	override function destroy() {
		// if(leTween != null) {
		// 	#if MODS_ALLOWED
		// 	if(isTransIn) {
		// 		Paths.destroyLoadedImages();
		// 	}
		// 	#end
		// 	finishCallback();
		// 	leTween.cancel();
		// }
		// super.destroy();
	}
}