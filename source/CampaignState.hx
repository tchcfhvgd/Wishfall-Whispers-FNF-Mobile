package;

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
import flixel.util.FlxTimer;
import flixel.text.FlxText;
import flixel.math.FlxMath;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import lime.app.Application;
import Achievements;
import CustomWipeTransition;
import editors.MasterEditorMenu;

#if sys
import sys.FileSystem;
#end

using StringTools;

class CampaignState extends MusicBeatState
{
	public static var curSelected:Int = 0;

	var menuItems:FlxTypedGroup<FlxSprite>;
	private var camGame:FlxCamera;
	private var camAchievement:FlxCamera;
	
	var optionShit:Array<String> = ['campaignA', 'campaignB'];

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

		var yScroll:Float = Math.max(0.25 - (0.05 * (optionShit.length - 4)), 0.1);
		var bg:FlxSprite = new FlxSprite(-80).loadGraphic(Paths.image('menuBGmorning'));
		if (MusicBeatState.worldTimeName == "morning")
			bg = new FlxSprite(-80).loadGraphic(Paths.image('menuBGmorning'));
		else if (MusicBeatState.worldTimeName == "day")
			bg = new FlxSprite(-80).loadGraphic(Paths.image('menuBGday'));
		else if (MusicBeatState.worldTimeName == "evening")
			bg = new FlxSprite(-80).loadGraphic(Paths.image('menuBGevening'));
		else if (MusicBeatState.worldTimeName == "night")
			bg = new FlxSprite(-80).loadGraphic(Paths.image('menuBGnight'));
		bg.scrollFactor.set(0, yScroll);
		bg.setGraphicSize(Std.int(bg.width * 1.175));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		
		add(bg);

		camFollow = new FlxObject(0, 0, 1, 1);
		camFollowPos = new FlxObject(0, 0, 1, 1);
		add(camFollow);
		add(camFollowPos);

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
			var offsetY:Float = 100 - (Math.max(optionShit.length, 4) - 4);
			var offsetX:Float = 150 - (Math.max(optionShit.length, 4) - 4);
			var menuItem:FlxSprite = new FlxSprite((i * 500) + offsetX, offsetY);
			menuItem.frames = Paths.getSparrowAtlas('mainmenu/menu_' + optionShit[i]);
			menuItem.animation.addByPrefix('idle', optionShit[i] + " basic", 24);
			menuItem.animation.addByPrefix('selected', optionShit[i] + " white", 24);
			menuItem.animation.play('idle');
			menuItem.ID = i;
			//menuItem.screenCenter(X);
			menuItems.add(menuItem);
			var scr:Float = (optionShit.length - 4) * 0.000;
			if(optionShit.length < 6) scr = 0;
			menuItem.scrollFactor.set(0, scr);
			menuItem.antialiasing = ClientPrefs.globalAntialiasing;
			menuItem.setGraphicSize(Std.int(menuItem.width * 0.55));
			menuItem.updateHitbox();
		}


			menuItems.forEach(function(menuItem:FlxSprite)
				{					
					
					FlxTween.angle(menuItem, menuItem.angle, -1, 2, {ease: FlxEase.sineInOut});
				});
			
		new FlxTimer().start(2, function(tmr:FlxTimer)
			{
				menuItems.forEach(function(menuItem:FlxSprite)
					{					
						if(menuItem.angle == -1) FlxTween.angle(menuItem, menuItem.angle, 1, 2, {ease: FlxEase.sineInOut});
						else FlxTween.angle(menuItem, menuItem.angle, -1, 2, {ease: FlxEase.sineInOut});
					});
	
			}, 0);



		FlxG.camera.follow(camFollowPos, null, 1);

		// var versionShit:FlxText = new FlxText(12, FlxG.height - 44, 0, "Psych Engine v" + psychEngineVersion, 12);
		// versionShit.scrollFactor.set();
		// versionShit.setFormat("a Anti Corona", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		// add(versionShit);
		// var versionShit:FlxText = new FlxText(12, FlxG.height - 24, 0, "Friday Night Funkin' v" + Application.current.meta.get('version'), 12);
		// versionShit.scrollFactor.set();
		// versionShit.setFormat("a Anti Corona", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		// add(versionShit);

		var text:FlxText = new FlxText(0, FlxG.height - 670, 0, "Choose a campaign!", 40);
		text.scrollFactor.set();
		text.screenCenter(X);
		text.x += 70;
		text.setFormat("a Anti Corona", 40, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(text);

		var scrLogo:Float = 0.000;

		changeItem();
		var wipe:CustomWipeTransition = new CustomWipeTransition();
		wipe.startVideoWipe('wipeIn');

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
		// #end

		super.create();
	}

	// #if ACHIEVEMENTS_ALLOWED
	// // Unlocks "Freaky on a Friday Night" achievement
	// function giveAchievement() {
	// 	add(new AchievementObject('friday_night_play', camAchievement));
	// 	FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);
	// 	trace('Giving achievement "friday_night_play"');
		
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
			if (controls.UI_LEFT_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(-1);
			}

			if (controls.UI_RIGHT_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(1);
			}

			if (controls.BACK)
			{
				selectedSomethin = true;
				FlxG.sound.play(Paths.sound('cancelMenu'));
				MusicBeatState.switchState(new MainMenuState());
			}

			if (controls.ACCEPT)
			{
				if (optionShit[curSelected] == 'donate')
				{
					CoolUtil.browserLoad('https://ninja-muffin24.itch.io/funkin');
				}
				else
				{
					selectedSomethin = true;
					FlxG.sound.play(Paths.sound('confirmMenu'));

					//if(ClientPrefs.flashing) FlxFlicker.flicker(magenta, 1.1, 0.15, false);

					menuItems.forEach(function(spr:FlxSprite)
					{
						// FlxTween.tween(spr, {x: 1500}, 2, {ease: FlxEase.quadOut});
						// FlxTween.tween(spr, {alpha: 0}, 0.4, {
						// 	ease: FlxEase.quadOut,
						// 	onComplete: function(twn:FlxTween)
						// 	{
						// 		logoBl.kill();
						// 	}
						// });
						var poop:Int = 0;
						if(spr.x > 400)	poop = 1000; else poop = -400;
						
						if (curSelected != spr.ID)
						{
							//trace(spr.x);
							FlxTween.tween(spr, {x: poop}, 1, {ease: FlxEase.sineInOut});
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
							var wipe:CustomWipeTransition = new CustomWipeTransition();
							new FlxTimer().start(0.35, function(tmr:FlxTimer)
								{
									wipe.startVideoWipe('wipeOut');
									// var black:FlxSprite = new FlxSprite(-100, -100).makeGraphic(1000, 1000, FlxColor.BLACK);
									// add(black);
								});
							FlxTween.tween(spr, {x: 400}, 1, {ease: FlxEase.sineInOut});
							FlxFlicker.flicker(spr, 1, 0.06, false, false, function(flick:FlxFlicker)
							{
								var daChoice:String = optionShit[curSelected];

								switch (daChoice)
								{
									case 'campaignA':
										MusicBeatState.switchState(new StoryMenuState());
									case 'campaignB':
										MusicBeatState.switchState(new StoryMenuBState());
									//case 'awards':
									//	MusicBeatState.switchState(new AchievementsMenuState());
									// case 'credits':
									// 	MusicBeatState.switchState(new CreditsState());
									// case 'options':
									// 	MusicBeatState.switchState(new OptionsState());
								}
							});
						}
					});
				}
			}
			#if desktop
			else if (FlxG.keys.justPressed.SEVEN)
			{
				//selectedSomethin = true;
				//MusicBeatState.switchState(new MasterEditorMenu());
			}
			#end
		}

		super.update(elapsed);

		menuItems.forEach(function(spr:FlxSprite)
		{
			//spr.screenCenter(X);
		});
	}

	function changeItem(huh:Int = 0)
	{
		curSelected += huh;

		if (curSelected >= menuItems.length)
			curSelected = 0;
		if (curSelected < 0)
			curSelected = menuItems.length - 1;

		menuItems.forEach(function(spr:FlxSprite)
		{
			spr.animation.play('idle');
			spr.offset.y = 0;
			spr.updateHitbox();

			if (spr.ID == curSelected)
			{
				spr.animation.play('selected');
				camFollow.setPosition(spr.getGraphicMidpoint().x, spr.getGraphicMidpoint().y);
				//spr.offset.x = (0.15 * (spr.frameWidth / 2 + 180)) + 92;
				//spr.offset.y = (0.15 * spr.frameHeight) + 25;
				FlxG.log.add(spr.frameWidth);
			}
		});
	}
}
