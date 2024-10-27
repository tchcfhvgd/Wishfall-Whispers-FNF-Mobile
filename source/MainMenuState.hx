package;

import flixel.addons.effects.chainable.FlxShakeEffect;
#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.util.FlxTimer;
import flixel.math.FlxMath;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import lime.app.Application;
import Achievements;
import editors.MasterEditorMenu;

#if sys
import sys.FileSystem;
#end

using StringTools;

class MainMenuState extends MusicBeatState
{
	public static var psychEngineVersion:String = '0.4.2'; //This is also used for Discord RPC
	public static var wishfallVersion:String = '0.1.0'; //This is also used for Discord RPC
	public static var curSelected:Int = 0;

	var menuItems:FlxTypedGroup<FlxSprite>;
	private var camGame:FlxCamera;
	private var camAchievement:FlxCamera;
	
	//var optionShit:Array<String> = ['story_mode', 'extras', /*#if ACHIEVEMENTS_ALLOWED 'awards', #end*/ 'credits', #if !switch 'donate', #end 'options'];
	var optionShit:Array<String> = ['story_mode', 'extras', /*#if ACHIEVEMENTS_ALLOWED 'awards', #end*/ 'credits', 'options'];

	var magenta:FlxSprite;
	var camFollow:FlxObject;
	var camFollowPos:FlxObject;

	var logoSpr:FlxSprite;
	var logoBl:FlxSprite;

	override function create()
	{
		
		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		camGame = new FlxCamera();
		camAchievement = new FlxCamera();
		camAchievement.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camAchievement);
		FlxCamera.defaultCameras = [camGame];

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		persistentUpdate = persistentDraw = true;

		camFollow = new FlxObject(0, 0, 1, 1);
		camFollowPos = new FlxObject(0, 0, 1, 1);
		add(camFollow);
		add(camFollowPos);

		var yScroll:Float = Math.max(0.25 - (0.05 * (optionShit.length - 4)), 0.1);
		var bg:FlxSprite = new FlxSprite(-80).loadGraphic(Paths.image('menuBGevening'));
		if (MusicBeatState.worldTimeName == "morning")
			{
				bg = new FlxSprite(-80).loadGraphic(Paths.image('menuBGmorning'));
				FlxG.save.data.playedMorning = true;
			}
		else if (MusicBeatState.worldTimeName == "day")
			{	
				bg = new FlxSprite(-80).loadGraphic(Paths.image('menuBGday'));
				FlxG.save.data.playedDay = true;
			}
		else if (MusicBeatState.worldTimeName == "evening")
			{
				bg = new FlxSprite(-80).loadGraphic(Paths.image('menuBGevening'));
				FlxG.save.data.playedEvening = true;
			}
		else if (MusicBeatState.worldTimeName == "night")
			{
				FlxG.save.data.playedNight = true;
				bg = new FlxSprite(-80).loadGraphic(Paths.image('menuBGnight'));
			}
				



		bg.scrollFactor.set(camFollow.x, yScroll * 0.7);
		bg.setGraphicSize(Std.int(bg.width * 0.8));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		
		add(bg);
		bg.x = bg.x - 14;
		FlxTween.tween(bg, {x: bg.x + 14}, 5, {ease: FlxEase.sineInOut, type: PINGPONG});
		FlxTween.tween(bg, {y: bg.y + 14}, 10, {ease: FlxEase.sineInOut, type: PINGPONG});
		//FlxTween.angle(bg, bg.angle, 1, 10, {ease: FlxEase.sineInOut, type: PINGPONG});

		//var yScroll:Float = Math.max(0.25 - (0.05 * (optionShit.length - 4)), 0.1);
		var bgfore:FlxSprite = new FlxSprite(-80).loadGraphic(Paths.image('menufore'));
		bgfore.scrollFactor.set(camFollow.x, yScroll * 1.5);
		bgfore.setGraphicSize(Std.int(bgfore.width * 0.7));

		//if (MusicBeatState.worldTimeName == "morning")
			//bgfore.color = 0xffffffff;
		//else if (MusicBeatState.worldTimeName == "day")
			//bgfore.color = 0xffffffff;

		bgfore.updateHitbox();
		bgfore.screenCenter();
		bgfore.x = bgfore.x - 20;
		bgfore.y = bgfore.y + 61;
		bgfore.antialiasing = ClientPrefs.globalAntialiasing;
		
		add(bgfore);
		bgfore.x = bgfore.x -10;
		FlxTween.tween(bgfore, {x: bgfore.x + 40}, 5, {ease: FlxEase.sineInOut, type: PINGPONG});
		FlxTween.tween(bgfore, {y: bgfore.y + 25}, 10, {ease: FlxEase.sineInOut, type: PINGPONG});
		//FlxTween.angle(bgfore, bgfore.angle, 1, 10, {ease: FlxEase.sineInOut, type: PINGPONG});



		magenta = new FlxSprite(-80).loadGraphic(Paths.image('menuDesat'));
		magenta.scrollFactor.set(0, yScroll);
		magenta.setGraphicSize(Std.int(magenta.width * 1.175));
		magenta.updateHitbox();
		magenta.screenCenter();
		magenta.visible = false;
		magenta.antialiasing = ClientPrefs.globalAntialiasing;
		magenta.color = 0xFFfd719b;
		add(magenta);
		// magenta.scrollFactor.set();

		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

		for (i in 0...optionShit.length)
		{
			var offsetY:Float = 300 - ((Math.max(optionShit.length, 4) - 4) * 40);
			var offsetX:Float = 200;
			var menuItem:FlxSprite = new FlxSprite(offsetX, (i * 60) + offsetY);

			menuItem.frames = Paths.getSparrowAtlas('mainmenu/menu_' + optionShit[i]);
			menuItem.animation.addByPrefix('idle', optionShit[i] + " basic", 24);
			menuItem.animation.addByPrefix('selected', optionShit[i] + " white", 24);
			//animOffsets['selected'] = [menuItem.x - 100,menuItem.y]

			menuItem.animation.play('idle');
			//var menuItem:FlxSprite = new FlxSprite(offsetX + menuItem.width, (i * 60) + offsetY);
			menuItem.ID = i;
			menuItem.screenCenter(X);
			menuItem.x = menuItem.x + offsetX;
			menuItems.add(menuItem);
			var scr:Float = (optionShit.length - 4) * 0.000;
			if(optionShit.length < 6) scr = 0;
			menuItem.scrollFactor.set(0, scr);
			menuItem.antialiasing = ClientPrefs.globalAntialiasing;
			menuItem.setGraphicSize(Std.int(menuItem.width * 0.40));
			menuItem.updateHitbox();
		}

		// for (i in 0...optionShit.length)
		// 	{
		// 		var offset:Float = 108 - (Math.max(optionShit.length, 4) - 4) * 80;
		// 		var menuItem:FlxSprite = new FlxSprite(0, (i * 140)  + offset);
		// 		menuItem.frames = Paths.getSparrowAtlas('mainmenu/menu_' + optionShit[i]);
		// 		menuItem.animation.addByPrefix('idle', optionShit[i] + " basic", 24);
		// 		menuItem.animation.addByPrefix('selected', optionShit[i] + " white", 24);
		// 		menuItem.animation.play('idle');
		// 		menuItem.ID = i;
		// 		menuItem.screenCenter(X);
		// 		menuItems.add(menuItem);
		// 		var scr:Float = (optionShit.length - 4) * 0.135;
		// 		if(optionShit.length < 6) scr = 0;
		// 		menuItem.scrollFactor.set(0, scr);
		// 		menuItem.antialiasing = ClientPrefs.globalAntialiasing;
		// 		menuItem.setGraphicSize(Std.int(menuItem.width * 0.40));
		// 		menuItem.updateHitbox();
		// 	}



		FlxG.camera.follow(camFollowPos, null, 1);

		if(MusicBeatState.glutoMode)
			{
				var versionShit:FlxText = new FlxText(12, FlxG.height - 44, 0, "Great" + psychEngineVersion, 12);
				versionShit.scrollFactor.set();
				versionShit.setFormat("a Anti Corona", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
				add(versionShit);
				var versionShit:FlxText = new FlxText(12, FlxG.height - 24, 0, "Prince" + Application.current.meta.get('version'), 12);
				versionShit.scrollFactor.set();
				versionShit.setFormat("a Anti Corona", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
				add(versionShit);
				var versionShit:FlxText = new FlxText(12, FlxG.height - 64, 0, "Gluto" + wishfallVersion, 12);
				versionShit.scrollFactor.set();
				versionShit.setFormat("a Anti Corona", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
				add(versionShit);
			}
		else 
		{
		var versionShit:FlxText = new FlxText(12, FlxG.height - 24, 0, "Psych Engine v" + psychEngineVersion, 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("a Anti Corona", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);
		// var versionShit:FlxText = new FlxText(12, FlxG.height - 64, 0, "Friday Night Funkin' v" + Application.current.meta.get('version'), 12);
		// versionShit.scrollFactor.set();
		// versionShit.setFormat("a Anti Corona", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		// add(versionShit);
		var versionShit:FlxText = new FlxText(12, FlxG.height - 44, 0, "Wishfall Whispers' v" + wishfallVersion, 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("a Anti Corona", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);
		}

		var scrLogo:Float = 0.000;
		//if(optionShit.length < 6) scrLogo = 0;
		
		
		
		logoBl = new FlxSprite(-500, 50);
		if(MusicBeatState.glutoMode)
			logoBl.frames = Paths.getSparrowAtlas('logoGluto');
		else
			logoBl.frames = Paths.getSparrowAtlas('logoBumpin');
		logoBl.antialiasing = ClientPrefs.globalAntialiasing;
		logoBl.screenCenter(X);
		logoBl.x = logoBl.x + 65;
		//logoBl.animation.addByPrefix('bump', 'logo bumpin', 24);
		//logoBl.animation.play('bump');
		logoBl.scrollFactor.set(0, scrLogo);
		logoBl.setGraphicSize(Std.int(logoBl.width * 0.50));
		logoBl.updateHitbox();
		
		if (MusicBeatState.worldTimeName == "evening")
			{
				bgfore.color = 0xffffc9c9;
				logoBl.color = 0xfffff1fd;
			}
		else if (MusicBeatState.worldTimeName == "night")
		bgfore.color = 0xff9e97ca;

		add(logoBl);

		//logoBl.angle = -2;
		// FlxTween.tween(logoBl, {y: logoBl.y + 10}, 5, {ease: FlxEase.sineInOut, type: PINGPONG});
		// FlxTween.angle(logoBl, logoBl.angle, 2, 10, {ease: FlxEase.sineInOut, type: PINGPONG});
		
		var logo:FlxSprite = new FlxSprite().loadGraphic(Paths.image('logo'));
		logo.screenCenter();
		logo.antialiasing = ClientPrefs.globalAntialiasing;



		logoSpr = new FlxSprite(0, FlxG.height * 0.4).loadGraphic(Paths.image('titlelogo'));
		add(logoSpr);
		logoSpr.visible = false;
		logoSpr.setGraphicSize(Std.int(logoSpr.width * 0.55));
		logoSpr.updateHitbox();
		logoSpr.screenCenter(X);
		logoSpr.antialiasing = ClientPrefs.globalAntialiasing;
		logoSpr.scrollFactor.set(0, scrLogo);
		logoSpr.updateHitbox();

		//startVideoWipe('wipeIn');


		// NG.core.calls.event.logEvent('swag').send();

		changeItem();

		// #if ACHIEVEMENTS_ALLOWED
		// Achievements.loadAchievements();
		// var leDate = Date.now();
		// if (leDate.getDay() == 5 && leDate.getHours() >= 18) {
		// 	var achieveID:Int = Achievements.getAchievementIndex('friday_night_play');
		// 	if(!Achievements.isAchievementUnlocked(Achievements.achievementsStuff[achieveID][2])) { //It's a friday night. WEEEEEEEEEEEEEEEEEE
		// 		Achievements.achievementsMap.set(Achievements.achievementsStuff[achieveID][2], true);
		// 		giveAchievement();
		// 		ClientPrefs.saveSettings();
		// 	}
		// }
		// if(FlxG.save.data.playedNight && FlxG.save.data.playedMorning && FlxG.save.data.playedDay && FlxG.save.data.playedEvening) {
		// 	var achieveID:Int = Achievements.getAchievementIndex('menu_alltime');
		// 	if(!Achievements.isAchievementUnlocked(Achievements.achievementsStuff[achieveID][2])) { //It's a friday night. WEEEEEEEEEEEEEEEEEE
		// 		Achievements.achievementsMap.set(Achievements.achievementsStuff[achieveID][2], true);
		// 		giveAchievement2();
		// 		ClientPrefs.saveSettings();
		// 	}
		// }
		// #end
	        var wipe:CustomWipeTransition = new CustomWipeTransition();
		wipe.startVideoWipe('wipeIn');
		
		super.create();
	}



	// #if ACHIEVEMENTS_ALLOWED
	// // Unlocks "Freaky on a Friday Night" achievement
	// function giveAchievement() {
	// 	add(new AchievementObject('friday_night_play', camAchievement));
	// 	FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);
	// 	trace('Giving achievement "friday_night_play"');
		
	// }

	// // Unlocks "Freaky on a Friday Night" achievement
	// function giveAchievement2() {
	// 	add(new AchievementObject('menu_alltime', camAchievement));
	// 	FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);
	// 	trace('Giving achievement "menu_alltime"');
		
	// }
	// #end

	var selectedSomethin:Bool = false;

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.8)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		var lerpVal:Float = CoolUtil.boundTo(elapsed * 5.6, 0, 1);
		camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x, camFollow.x, lerpVal), FlxMath.lerp(camFollowPos.y, camFollow.y, lerpVal));

		if (!selectedSomethin)
		{
			if (controls.UI_UP_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(-1);
			}

			if (controls.UI_DOWN_P)
			{
				
				
				// 	 return Function_Stop
				// end
				// return Function_Continue
				// end

				// PlayMedia.di = ['video','wiped','no'];
				// MusicBeatState.switchState(new PlayMedia());

				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(1);
			}

			if (controls.BACK)
			{
				selectedSomethin = true;
				FlxG.sound.play(Paths.sound('cancelMenu'));
				MusicBeatState.switchState(new TitleState());
			}

			if (controls.ACCEPT)
			{
				if (optionShit[curSelected] == 'donate')
				{
					CoolUtil.browserLoad('https://ninja-muffin24.itch.io/funkin');
				}
				else
				{
					//startVideoWipe('wipeOut');
					//PlayMedia.startVideo('wipe');

					selectedSomethin = true;
					FlxG.sound.play(Paths.sound('confirmMenu'));

					//if(ClientPrefs.flashing) FlxFlicker.flicker(magenta, 1.1, 0.15, false);

					FlxTween.tween(logoBl, {x: 1500}, 2, {ease: FlxEase.sineInOut});
					FlxTween.tween(logoBl, {alpha: 0}, 0.4, {
						ease: FlxEase.quadOut,
						onComplete: function(twn:FlxTween)
						{
							logoBl.kill();
						}
					});


					menuItems.forEach(function(spr:FlxSprite)
					{
						if (curSelected != spr.ID)
						{
							FlxTween.tween(spr, {x: -500}, 2, {ease: FlxEase.sineInOut});

							FlxTween.tween(spr, {alpha: 0}, 0.4, {
								ease: FlxEase.quadOut,
								onComplete: function(twn:FlxTween)
								{
									spr.kill();
								}
							});
						}
						else
						{	
									new FlxTimer().start(0.35, function(tmr:FlxTimer)
								{
								        var wipe:CustomWipeTransition = new CustomWipeTransition();
									wipe.startVideoWipe('wipeOut');
		
									// var black:FlxSprite = new FlxSprite(-100, -100).makeGraphic(1000, 1000, FlxColor.BLACK);
									// add(black);
								});

							FlxFlicker.flicker(spr, 1, 0.06, false, false, function(flick:FlxFlicker)
							{
								var daChoice:String = optionShit[curSelected];

								switch (daChoice)
								{
									case 'story_mode':
										MusicBeatState.switchState(new CampaignState());
									case 'extras':
										MusicBeatState.switchState(new ExtrasState());
									// case 'awards':
									// 	MusicBeatState.switchState(new AchievementsMenuState());
									case 'credits':
										MusicBeatState.switchState(new CreditsState());
									case 'options':
										MusicBeatState.switchState(new OptionsState());
								}
							});
						}
					});
				}
			}
			#if desktop
			else if (FlxG.keys.justPressed.SEVEN)
			{
				selectedSomethin = true;
				MusicBeatState.switchState(new MasterEditorMenu());
			}
			#end
		}

		super.update(elapsed);

		menuItems.forEach(function(spr:FlxSprite)
		{
			//spr.screenCenter(X);
		});
	}
	// private function startVideoWipe(name:String):Void {
	// 	#if VIDEOS_ALLOWED
	// 	var foundFile:Bool = false;
	// 	var fileName:String = #if MODS_ALLOWED Paths.modFolders('videos/' + name + '.' + Paths.VIDEO_EXT); #else ''; #end
	// 	#if sys
	// 	if(FileSystem.exists(fileName)) {
	// 		foundFile = true;
	// 	}
	// 	#end

	// 	if(!foundFile) {
	// 		fileName = Paths.video(name);
	// 		#if sys
	// 		if(FileSystem.exists(fileName)) {
	// 		#else
	// 		if(OpenFlAssets.exists(fileName)) {
	// 		#end
	// 			foundFile = true;
	// 		}
	// 	}

	// 	if(foundFile) {
	// 		//inCutscene = true;
	// 		// var bg2 = new FlxSprite(-FlxG.width, -FlxG.height).makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.BLACK);
	// 		// bg2.scrollFactor.set();
	// 		// bg2.cameras = [camGame];
	// 		// add(bg2);
	// 		(new FlxVideo(fileName)).finishCallback = function() {
				
	// 			trace('shit');
	// 			//remove(bg2);
	// 			// if(endingSong) {
	// 			// 	endSong();
	// 			// } else {
	// 			// 	startCountdown();
	// 			// }
	// 		}
	// 		return;
	// 	} else {
	// 		FlxG.log.warn('Couldnt find video file: ' + fileName);
	// 	}
	// 	#end
	// 	// if(endingSong) {
	// 	// 	endSong();
	// 	// } else {
	// 	// 	startCountdown();
	// 	// }
	// }

	function changeItem(huh:Int = 0)
	{
		curSelected += huh;

		if (curSelected >= menuItems.length)
			curSelected = 0;
		if (curSelected < 0)
			curSelected = menuItems.length - 1;

		menuItems.forEach(function(spr:FlxSprite)
		{
			var wait:Bool = false;
			//spr.animation.play('idle');
			spr.animation.play('idle');
			spr.offset.y = 0;
			//spr.updateHitbox();
			if (spr.ID != curSelected) {FlxTween.tween(spr, {'scale.x': 0.4, 'scale.y': 0.4}, 0.15, {ease: FlxEase.quadInOut, type: ONESHOT});}
			

			if (spr.ID == curSelected)
			{
				//spr.updateHitbox();
				spr.animation.play('selected');
				
				FlxTween.tween(spr, {'scale.x': 0.45, 'scale.y': 0.45}, 0.15, {ease: FlxEase.quadInOut, 
					onStart: function (twn:FlxTween){wait = true;}, onComplete: function (twn:FlxTween){
						
						// wait = false;
					
						// if (wait == false)
						// 	{
						// 		FlxTween.tween(spr, {'scale.x': 0.4, 'scale.y': 0.4}, 0.15, {ease: FlxEase.quadInOut, type: ONESHOT});
						// 	}
						
						}});
				camFollow.setPosition(spr.getGraphicMidpoint().x, spr.getGraphicMidpoint().y);
				//spr.offset.x = (0.15 * (spr.frameWidth / 2 + 180)) + 92;
				//spr.offset.y = (0.15 * spr.frameHeight) + 25;
				FlxG.log.add(spr.frameWidth);
				
			}

		});
	}
}
