//
//  AudioManager.m
//  MakeAMealOfIt
//
//  Created by James Valaitis on 08/08/2013.
//  Copyright (c) 2013 &Beyond. All rights reserved.
//

#import "AudioManager.h"
@import AudioToolbox;

#pragma mark - Audio Manager Private Class Extension

@interface AudioManager () {}

@end

#pragma mark - Audio Manager Implementation

@implementation AudioManager {}

#pragma mark - Playing Audio

/**
 *	Plays a sound.
 *
 *	@param	fileName				The file name of the piece of audio to play.
 *	@param	extension				The file extension for the piece of audio.
 */
+ (void)playSound:(NSString *)fileName withExtension:(NSString *)extension
{
	SystemSoundID completeSound;
	NSURL *audioPath				= [[NSBundle mainBundle] URLForResource:fileName withExtension:extension];
	AudioServicesCreateSystemSoundID((__bridge CFURLRef)audioPath, &completeSound);
	AudioServicesPlaySystemSound(completeSound);
}

@end