//
//  AppDelegate.m
//  MakeAMealOfIt
//
//  Created by James Valaitis on 14/04/2013.
//  Copyright (c) 2013 &Beyond. All rights reserved.
//

//	crash reporting and testing
#import <HockeySDK/HockeySDK.h>

//	other imports
#import "AppDelegate.h"
#import "CupboardViewController.h"
#import "ExtraOptionsViewController.h"
#import "Reachability.h"
#import "RecipeSearchViewController.h"
#import "SlideNavigationController.h"
#import "YummlyTheme.h"

#pragma mark - App Delegate Private Class Extension

@interface AppDelegate () <BITCrashManagerDelegate, BITFeedbackComposeViewControllerDelegate, BITHockeyManagerDelegate, BITUpdateManagerDelegate> {}

@end

#pragma mark - App Delegate Implementation

@implementation AppDelegate

#pragma mark - Action & Selector Methods

/**
 *	Called when the user has updated their preferred text size.
 */
- (void)preferredTextSizeChanged
{
	[ThemeManager setSharedTheme:[[YummlyTheme alloc] init]];
	[[NSNotificationCenter defaultCenter] postNotificationName:kNotificationTextSizeChanged object:nil];
}

/**
 *	Called when internet reachability has changed in some way.
 *
 *	@param	notification				The object containing a name, an object, and an optional dictionary.
 */
- (void)reachabilityChanged:(NSNotification*)notification
{
    Reachability *reachability			= notification.object;
    
    if (reachability.isReachable)
    {
    }
	
    else
    {
    }
}

#pragma mark - BITUpdateManager Methods

/**
 *	Sent to the delegate to get the device identifier.
 *
 *	@param	updateManager				The BITUpdateManager instance invoking this delegate.
 *
 *	@return	Return the device UDID which is required for beta testing, should return nil for app store configuration.
 */
- (NSString *)customDeviceIdentifierForUpdateManager:(BITUpdateManager *)updateManager
{
#ifndef CONFIGURATION_AppStore
	if ([[UIDevice currentDevice] respondsToSelector:@selector(uniqueIdentifier)])
		return [[UIDevice currentDevice] performSelector:@selector(uniqueIdentifier)];
#endif
	
	return nil;
}

#pragma mark - UIApplicationDelegate Methods

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
	
	RecipeSearchViewController *centre	= [[RecipeSearchViewController alloc] init];
	CupboardViewController *left		= [[CupboardViewController alloc] init];
	ExtraOptionsViewController*right	= [[ExtraOptionsViewController alloc] init];
	
	SlideNavigationController *slideNav	= [[SlideNavigationController alloc] initWithCentreViewController:centre
																					   leftViewController:left
																				   andRightViewController:right];
	
	
	self.window.rootViewController		= slideNav;
	
	[ThemeManager setSharedTheme:[[YummlyTheme alloc] init]];
	
	[self.window makeKeyAndVisible];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(preferredTextSizeChanged)
												 name:UIContentSizeCategoryDidChangeNotification
											   object:nil];
	
	self.yummlyRequest					= [[YummlyRequest alloc] init];
	
	[[BITHockeyManager sharedHockeyManager] configureWithIdentifier:@"4bcab055c4b96cfd9451cfc6afacde49" delegate:self];
	[[BITHockeyManager sharedHockeyManager] startManager];
	
    return YES;
}

/**
 *	Asks the delegate whether the app’s saved state information should be restored.
 *
 *	@param	The delegating application object.
 *	@param	The keyed archiver containing the app’s previously saved state information.
 *
 *	@return	YES if the app’s state should be restored or NO if it should not.
 */
- (BOOL)application:(UIApplication *)application shouldRestoreApplicationState:(NSCoder *)coder
{
	return NO;
}

/**
 *	Asks the delegate whether the app’s state should be preserved.
 *
 *	@param	application					The delegating application object.
 *	@param	coder						The keyed archiver into which you can put high-level state information.
 *
 *	@return	YES if the app’s state should be preserved or NO if it should not.
 */
- (BOOL)application:(UIApplication *)application shouldSaveApplicationState:(NSCoder *)coder
{
	return NO;
}

/**
 *	Tells the delegate that the application has become active.
 *
 *	@param	application					The singleton application instance.
 */
- (void)applicationDidBecomeActive:(UIApplication *)application
{
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(reachabilityChanged:)
												 name:kReachabilityChangedNotification
											   object:nil];
	Reachability *reachability			= [Reachability reachabilityWithHostname:@"www.yummly.com"];
	[reachability startNotifier];
}

@end