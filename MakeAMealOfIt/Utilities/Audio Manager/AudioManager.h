//
//  AudioManager.h
//  MakeAMealOfIt
//
//  Created by James Valaitis on 08/08/2013.
//  Copyright (c) 2013 &Beyond. All rights reserved.
//

#pragma mark - Audio Manager Public Interface

@interface AudioManager : NSObject {}

#pragma mark - Public Methods

/**
 *	Plays a sound.
 *
 *	@param	fileName				The file name of the piece of audio to play.
 *	@param	extension				The file extension for the piece of audio.
 */
+ (void)playSound:(NSString *)fileName withExtension:(NSString *)extension;

@end