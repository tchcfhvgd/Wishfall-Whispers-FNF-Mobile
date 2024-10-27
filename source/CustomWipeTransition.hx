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
	var isTransIn:Bool = false;

	public function new() {
		super();

	}

	public function startVideoWipe(name:String):Void {

		if(!ClientPrefs.lowQuality)
		{
			var video:FlxVideo = new FlxVideo();
		        video.load(Paths.video(name));
		        video.play();
		        video.onEndReached.add(function()
		        {
			        video.dispose();
				if(name == "wipeOut")
						{
							trace("BOOTIE BOY");
							CustomFadeTransition.screenBlack();
							
						}
			        return;
		        }, true);
		}
	}

	override function update(elapsed:Float) {

	}

	override function destroy() {
	}
}
