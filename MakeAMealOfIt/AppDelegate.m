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
 *	Tells the delegate that the launch process is almost done and the app is almost ready to run.
 *
 *	@param	application					The delegating application object.
 *	@param	launchOptions				A dictionary indicating the reason the application was launched (if any).
 */
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window							= [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor			= [UIColor whiteColor];
	self.window.tintColor				= kYummlyColourMain;
	
	//	set up shared cache for url requests
	NSArray *directories				= [[NSFileManager defaultManager] URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask];
	NSString *path						= [[(NSURL *)directories[0] URLByAppendingPathComponent:@"NSURLCache"] absoluteString];
	NSURLCache *URLCache				= [[NSURLCache alloc] initWithMemoryCapacity:4 * 1024 * 1024
														 diskCapacity:20 * 1024 * 1024
															 diskPath:path];
	[NSURLCache setSharedURLCache:URLCache];
	
	self.slideOutVC						= [[SlideOutNavigationController alloc] init];
	self.window.rootViewController		= self.slideOutVC.mainViewController;
	
	[ThemeManager setSharedTheme:[[YummlyTheme alloc] init]];
	
	[self.window makeKeyAndVisible];
	
	self.yummlyRequest					= [[YummlyRequest alloc] init];
	self.yummlyRequest.requirePictures	= YES;
	
    return YES;
}

@end
