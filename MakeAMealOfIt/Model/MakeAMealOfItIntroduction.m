//
//  MakeAMealOfItIntroduction.m
//  MakeAMealOfIt
//
//  Created by James Valaitis on 14/08/2013.
//  Copyright (c) 2013 &Beyond. All rights reserved.
//

#import "IntroductionView.h"
#import "MakeAMealOfItIntroduction.h"

#pragma mark - Constants & Static Variables

static NSString *const kIntroductionHasBeenShownKey	= @"IntroductionHasBeenShown";
static NSString *const kPanelDescriptionKey			= @"Description";
static NSString *const kPanelImageNameKey			= @"Image";
static NSString *const kPanelTitleKey				= @"Title";

#pragma mark - Make A Meal Of It Introduction Implementation

@implementation MakeAMealOfItIntroduction

#pragma mark - Property Accessor Methods - Getters

/**
 *	The IntroductionPanelViews to show in a IntroductionView.
 *
 *	@return	An array of panels suitable to be shown in a MYIntroductionView.
 */
+ (NSArray *)initialisedPanels
{
	NSMutableArray *panels				= [[NSMutableArray alloc] init];
	NSArray *panelDefinitions			= [self panelDefinitions];
	
	for (NSDictionary *panelDefinition in panelDefinitions)
	{
		NSString *description			= panelDefinition[kPanelDescriptionKey];
		UIImage *image					= [UIImage imageNamed:panelDefinition[kPanelImageNameKey]];
		NSString *title					= panelDefinition[kPanelTitleKey];
		
		IntroductionPanelView *panel	= [[IntroductionPanelView alloc] initWithTitle:title description:description andImage:image];
		[panels addObject:panel];
	}
	
	return panels;
}

/**
 *	Whether or not the introduction has already been shown or not.
 *
 *	@return	YES if the introduction for this app has already been shown, NO otherwise.
 */
+ (BOOL)introductionHasBeenShown
{
	return [[NSUserDefaults standardUserDefaults] boolForKey:kIntroductionHasBeenShownKey];
}

/**
 *	Presents a fully initialised and configured IntroductionView specifically for introducing this app.
 *
 *	@param	frame						The desired frame for the introduction view.
 *	@param	view						The view in which to display the introduction view.
 */
+ (void)showIntroductionViewWithFrame:(CGRect)frame inView:(UIView *)view
{
	IntroductionView *introductionView		= [[IntroductionView alloc] initWithFrame:frame
																		   panels:self.initialisedPanels
																	   headerText:@"Make A Meal Of It"];
	
	[introductionView presentInView:view animated:YES];
}

/**
 *	Dictionaries defining MYIntroductionPanel objects.
 *
 *	@return	An NSArray of NSDictionaries each defining a MYIntroductionPanel int he order they should be displayed.
 */
+ (NSArray *)panelDefinitions
{
	NSString *panelPListPath			= [[NSBundle mainBundle] pathForResource:@"IntroductionPanels" ofType:@"plist"];
	NSArray *panelDefinitions			= [[NSArray alloc] initWithContentsOfFile:panelPListPath];
	return panelDefinitions;
}

#pragma mark - Property Accessor Methods - Setters

/**
 *	Whether or not the introduction has already been shown or not.
 *
 *	@param	hasBeenShown				Sets whether the introduction has now been shown or not.
 */
+ (void)setIntroductionHasBeenShown:(BOOL)hasBeenShown
{
	[[NSUserDefaults standardUserDefaults] setBool:hasBeenShown forKey:kIntroductionHasBeenShownKey];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

@end