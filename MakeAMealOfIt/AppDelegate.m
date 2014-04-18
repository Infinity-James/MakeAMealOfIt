//
//  AppDelegate.m
//  MakeAMealOfIt
//
//  Created by James Valaitis on 14/04/2013.
//  Copyright (c) 2013 &Beyond. All rights reserved.
//

//	other imports
#import "AppDelegate.h"
#import "CupboardViewController.h"
#import "ExtraOptionsViewController.h"
#import "Reachability.h"
#import "RecipeSearchViewController.h"
#import "SlideNavigationController.h"
#import "YummlyTheme.h"

#pragma mark - App Delegate Private Class Extension

@interface AppDelegate () {}

/**	Keeps track of whether there is an internet connection or not.	*/
@property (nonatomic, readwrite, assign)	BOOL				internetConnectionExists;

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
		[[NSNotificationCenter defaultCenter] postNotificationName:kNotificationInternetReconnected object:reachability];
		self.internetConnectionExists	= YES;
    }
	
    else
    {
		[[NSNotificationCenter defaultCenter] postNotificationName:kNotificationInternetConnectionLost object:reachability];
		self.internetConnectionExists	= NO;
    }
}

#pragma mark - Customisation

/**
 *	Customises objects app wide.
 */
- (void)customiseApp
{
	UINavigationBar *navigationBar		= [UINavigationBar appearance];
	navigationBar.barTintColor			= kYummlyColourMain;
	UIToolbar *toolbar					= [UIToolbar appearance];
	toolbar.barTintColor				= kYummlyColourMain;
}

#pragma mark - Reveal

#import <dlfcn.h>
- (void)loadReveal
{
    NSString *revealLibName = @"libReveal";
    NSString *revealLibExtension = @"dylib";
    NSString *dyLibPath = [[NSBundle mainBundle] pathForResource:revealLibName ofType:revealLibExtension];
    NSLog(@"Loading dynamic library: %@", dyLibPath);
	
    void *revealLib = NULL;
    revealLib = dlopen([dyLibPath cStringUsingEncoding:NSUTF8StringEncoding], RTLD_NOW);
	
    if (revealLib == NULL)
    {
        char *error = dlerror();
        NSLog(@"dlopen error: %s", error);
        NSString *message = [NSString stringWithFormat:@"%@.%@ failed to load with error: %s", revealLibName, revealLibExtension, error];
        [[[UIAlertView alloc] initWithTitle:@"Reveal library could not be loaded" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
}

#pragma mark - UIApplicationDelegate Methods

/**
 *	Tells the delegate that the launch process is almost done and the app is almost ready to run.
 *
 *	@param	application					The delegating application object.
 *	@param	launchOptions				A dictionary indicating the reason the application was launched (if any).
 *
 *	@return	NO if the application cannot handle the URL resource, otherwise return YES.
 */
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window							= [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor			= [UIColor whiteColor];
	self.window.tintColor				= [UIColor whiteColor];
	[UIApplication sharedApplication].statusBarStyle	= UIStatusBarStyleLightContent;
	
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
	
	[self customiseApp];
	[self.window makeKeyAndVisible];
	
	self.internetConnectionExists		= YES;
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(preferredTextSizeChanged)
												 name:UIContentSizeCategoryDidChangeNotification
											   object:nil];
	
	self.yummlyRequest					= [[YummlyRequest alloc] init];
	
	[self loadReveal];
	
    return YES;
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