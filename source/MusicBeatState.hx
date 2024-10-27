package;

import Conductor.BPMChangeEvent;
import flixel.FlxG;
import flixel.addons.ui.FlxUIState;
import flixel.math.FlxRect;
import flixel.util.FlxTimer;
import flixel.addons.transition.FlxTransitionableState;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.util.FlxGradient;
import flixel.FlxState;
import flixel.FlxBasic;
#if mobile
import mobile.MobileControls;
import mobile.flixel.FlxVirtualPad;
import flixel.FlxCamera;
import flixel.input.actions.FlxActionInput;
import flixel.util.FlxDestroyUtil;
#end

class MusicBeatState extends FlxUIState
{
	public static var worldTime:Date;
	public static var worldTimeName:String = "morning";

	private var lastBeat:Float = 0;
	private var lastStep:Float = 0;

	private var curStep:Int = 0;
	private var curBeat:Int = 0;
	private var controls(get, never):Controls;
	public static var glutoMode = false;

	inline function get_controls():Controls
		return PlayerSettings.player1.controls;

	#if mobile
		var mobileControls:MobileControls;
		var virtualPad:FlxVirtualPad;
		var trackedInputsMobileControls:Array<FlxActionInput> = [];
		var trackedInputsVirtualPad:Array<FlxActionInput> = [];

		public function addVirtualPad(DPad:FlxDPadMode, Action:FlxActionMode)
		{
		    if (virtualPad != null)
			removeVirtualPad();

			virtualPad = new FlxVirtualPad(DPad, Action);
		    add(virtualPad);

			controls.setVirtualPadUI(virtualPad, DPad, Action);
			trackedInputsVirtualPad = controls.trackedInputsUI;
			controls.trackedInputsUI = [];
		}

		public function removeVirtualPad()
		{
			if (trackedInputsVirtualPad.length > 0)
			controls.removeVirtualControlsInput(trackedInputsVirtualPad);

			if (virtualPad != null)
			remove(virtualPad);
		}

		public function addMobileControls(DefaultDrawTarget:Bool = true)
		{
			if (mobileControls != null)
			removeMobileControls();

			mobileControls = new MobileControls();

			switch (MobileControls.mode)
			{
				case 'Pad-Right' | 'Pad-Left' | 'Pad-Custom':
				controls.setVirtualPadNOTES(mobileControls.virtualPad, RIGHT_FULL, NONE);
				case 'Pad-Duo':
				controls.setVirtualPadNOTES(mobileControls.virtualPad, BOTH_FULL, NONE);
				case 'Hitbox':
				controls.setHitBox(mobileControls.hitbox);
				case 'Keyboard': // do nothing
			}

			trackedInputsMobileControls = controls.trackedInputsNOTES;
			controls.trackedInputsNOTES = [];

			var camControls:FlxCamera = new FlxCamera();
			FlxG.cameras.add(camControls, DefaultDrawTarget);
			camControls.bgColor.alpha = 0;

			mobileControls.cameras = [camControls];
			mobileControls.visible = false;
			add(mobileControls);
		}

		public function removeMobileControls()
		{
			if (trackedInputsMobileControls.length > 0)
			controls.removeVirtualControlsInput(trackedInputsMobileControls);

			if (mobileControls != null)
			remove(mobileControls);
		}

		public function addVirtualPadCamera(DefaultDrawTarget:Bool = true)
		{
			if (virtualPad != null)
			{
				var camControls:FlxCamera = new FlxCamera();
				FlxG.cameras.add(camControls, DefaultDrawTarget);
				camControls.bgColor.alpha = 0;
				virtualPad.cameras = [camControls];
			}
		}
		#end

		override function destroy()
		{
			#if mobile
			if (trackedInputsMobileControls.length > 0)
			controls.removeVirtualControlsInput(trackedInputsMobileControls);

			if (trackedInputsVirtualPad.length > 0)
			controls.removeVirtualControlsInput(trackedInputsVirtualPad);
			#end

			super.destroy();

			#if mobile
			if (virtualPad != null)
			virtualPad = FlxDestroyUtil.destroy(virtualPad);

			if (mobileControls != null)
			mobileControls = FlxDestroyUtil.destroy(mobileControls);
			#end
		}
	
	override function create() {
		var skip:Bool = FlxTransitionableState.skipNextTransOut;

		calculateTime();

		super.create();

		// Custom made Trans out
		if(!skip) {
			openSubState(new CustomFadeTransition(0.5, true));
		}
		
		FlxTransitionableState.skipNextTransOut = false;
	}

	private function calculateTime():Void
		{
			worldTime = Date.now();

		if(worldTime.getHours() >= 6 && worldTime.getHours() < 20)
		{
			if(worldTime.getHours() >= 11)
			{
				if(worldTime.getHours() < 17) worldTimeName = "day";
				else worldTimeName = "evening";
			}
			else 
				worldTimeName = "morning";
		}
		else worldTimeName = "night";
		}
	
	#if (VIDEOS_ALLOWED && windows)
	override public function onFocus():Void
	{
		FlxVideo.onFocus();
		super.onFocus();
	}
	
	override public function onFocusLost():Void
	{
		FlxVideo.onFocusLost();
		super.onFocusLost();
	}
	#end

	override function update(elapsed:Float)
	{
		//everyStep();
		var oldStep:Int = curStep;

		updateCurStep();
		updateBeat();

		if (oldStep != curStep && curStep > 0)
			stepHit();
			calculateTime();


		super.update(elapsed);
	}

	private function updateBeat():Void
	{
		curBeat = Math.floor(curStep / 4);
	}

	private function updateCurStep():Void
	{
		var lastChange:BPMChangeEvent = {
			stepTime: 0,
			songTime: 0,
			bpm: 0
		}
		for (i in 0...Conductor.bpmChangeMap.length)
		{
			if (Conductor.songPosition >= Conductor.bpmChangeMap[i].songTime)
				lastChange = Conductor.bpmChangeMap[i];
		}

		curStep = lastChange.stepTime + Math.floor(((Conductor.songPosition - ClientPrefs.noteOffset) - lastChange.songTime) / Conductor.stepCrochet);
	}

	public static function switchState(nextState:FlxState) {
		// Custom made Trans in
		var curState:Dynamic = FlxG.state;
		var leState:MusicBeatState = curState;
		if(!FlxTransitionableState.skipNextTransIn) {
			leState.openSubState(new CustomFadeTransition(0.5, false));
			if(nextState == FlxG.state) {
				CustomFadeTransition.finishCallback = function() {
					FlxG.resetState();
				};
				//trace('resetted');
			} else {
				CustomFadeTransition.finishCallback = function() {
					FlxG.switchState(nextState);
				};
				//trace('changed state');
			}
			return;
		}
		FlxTransitionableState.skipNextTransIn = false;
		FlxG.switchState(nextState);
	}

	public static function resetState() {
		MusicBeatState.switchState(FlxG.state);
	}

	public static function getState():MusicBeatState {
		var curState:Dynamic = FlxG.state;
		var leState:MusicBeatState = curState;
		return leState;
	}

	public function stepHit():Void
	{
		if (curStep % 4 == 0)
			beatHit();
	}

	public function beatHit():Void
	{
		//do literally nothing dumbass
	}
}
