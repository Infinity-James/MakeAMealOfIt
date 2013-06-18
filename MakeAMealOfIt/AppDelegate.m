//
//  AppDelegate.m
//  MakeAMealOfIt
//
//  Created by James Valaitis on 14/04/2013.
//  Copyright (c) 2013 &Beyond. All rights reserved.
//

#import "AppDelegate.h"
#import "YummlyTheme.h"

#pragma mark - App Delegate Implementation

@implementation AppDelegate

/**
 *	tells the delegate that the launch process is almost done and the app is almost ready to run
 *
 *	@param	application					the delegating application object
 *	@param	launchOptions				dictionary indicating the reason the application was launched (if any)
 */
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window							= [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor			= [UIColor whiteColor];
	self.window.tintColor				= kYummlyColourMain;
	
	
	
	self.slideOutVC						= [[SlideOutNavigationController alloc] init];
	self.window.rootViewController		= self.slideOutVC.mainViewController;
	
	[ThemeManager setSharedTheme:[[YummlyTheme alloc] init]];
	
	[self.window makeKeyAndVisible];
	
	self.yummlyRequest					= [[YummlyRequest alloc] init];
	self.yummlyRequest.requirePictures	= YES;
	
    return YES;
}

@end
