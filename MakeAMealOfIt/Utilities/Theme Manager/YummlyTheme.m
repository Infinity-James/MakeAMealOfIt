//
//  YummlyTheme.m
//  MakeAMealOfIt
//
//  Created by James Valaitis on 16/05/2013.
//  Copyright (c) 2013 &Beyond. All rights reserved.
//

#import "YummlyTheme.h"

#pragma mark - Yummly Theme Implementation

@implementation YummlyTheme {}

#pragma mark - Initialisation

/**
 *	called to initialise a class instance
 */
- (id)init
{
	if (self = [super init])
	{
		_coloursForGradient				= @[@[	[UIColor colorWithRed:0.969f green:0.976f blue:0.878f alpha:1.000f],
												[UIColor colorWithRed:0.753f green:0.749f blue:0.698f alpha:1.000f],
												[UIColor colorWithRed:0.976f green:0.976f blue:0.937f alpha:1.000f]],
											@[	@0.0f, @0.98f, @1.0f]];
	}
	
	return self;
}

#pragma mark - Theme Methods: Bar Button Item Appearance

/**
 *	returns a dictionary for the various properties associated with bar button items
 */
- (NSDictionary *)barButtonTextDictionary
{
	return @{	UITextAttributeFont				: [UIFont fontWithName:@"AvenirNext-Regular" size:16.0f],
				UITextAttributeTextColor		: [UIColor whiteColor],
				UITextAttributeTextShadowColor	: [UIColor colorWithWhite:0.8f alpha:1.0f],
				UITextAttributeTextShadowOffset	: [NSValue valueWithUIOffset:UIOffsetMake(0.0f, 1.0f)]};
}

/**
 *	returns image for standard bar button items depending on their state and the bar metrics
 *
 *	@param	controlState				the control state of the bar button that this image should represent
 *	@param	barMetrics					the bar metrics for whatever bar this item belongs to
 */
- (UIImage *)imageForBarButtonDoneForState:(UIControlState)controlState barMetrics:(UIBarMetrics)barMetrics
{
	//	returns images for standard bar button items when they are 44 points
	if (barMetrics == UIBarMetricsDefault)
		switch (controlState)
		{
			case UIControlStateNormal:			return [UIImage imageNamed:@"barbutton_default_yummly"];	break;
			case UIControlStateHighlighted:		break;
			default:							break;
		}
	
	//	returns images for standard bar button items when they are 32 points
	else if (barMetrics == UIBarMetricsLandscapePhone)
		switch (controlState)
		{
			case UIControlStateNormal:			break;
			case UIControlStateHighlighted:		break;
			default:							break;
		}
	
	return nil;
}

/**
 *	returns image for done bar button items depending on their state and the bar metrics
 *
 *	@param	controlState				the control state of the bar button that this image should represent
 *	@param	barMetrics					the bar metrics for whatever bar this item belongs to
 */
- (UIImage *)imageForBarButtonForState:(UIControlState)controlState barMetrics:(UIBarMetrics)barMetrics
{
	//	returns images for standard bar button items when they are 44 points
	if (barMetrics == UIBarMetricsDefault)
		switch (controlState)
		{
			case UIControlStateNormal:			return [UIImage imageNamed:@"barbutton_default_yummly_unsel"];		break;
			case UIControlStateHighlighted:		return [UIImage imageNamed:@"barbutton_default_yummly_sel"];		break;
			default:							break;
		}
	
	//	returns images for standard bar button items when they are 32 points
	else if (barMetrics == UIBarMetricsLandscapePhone)
		switch (controlState)
		{
			case UIControlStateNormal:			return [UIImage imageNamed:@"barbutton_landscape_yummly_unsel"];	break;
			case UIControlStateHighlighted:		return [UIImage imageNamed:@"barbutton_landscape_yummly_sel"];		break;
			default:							break;
		}
	
	return nil;
}

#pragma mark - Theme Methods: Button Appearance

/**
 *	returns a dictionary of properties for uibuttons
 */
- (NSDictionary *)buttonTextDictionary
{
	return @{	UITextAttributeFont				: [UIFont fontWithName:@"AvenirNext-Regular" size:16.0f],
				UITextAttributeTextColor		: kYummlyColourMain,
				UITextAttributeTextShadowColor	: kYummlyColourShadow,
				UITextAttributeTextShadowOffset	: [NSValue valueWithUIOffset:UIOffsetMake(0.0f, 1.0f)]};
}

/**
 *	returns an image for a button depending on the state
 *
 *	@param	controlState				the control state of the button
 */
- (UIImage *)imageForButtonWithState:(UIControlState)controlState
{
	switch (controlState)
	{
		case UIControlStateNormal:
			return [[UIImage imageNamed:@"button_background"] resizableImageWithCapInsets:UIEdgeInsetsMake(10.0f, 21.0f, 10.0f, 21.0f)
																			 resizingMode:UIImageResizingModeStretch];
			break;
		case UIControlStateHighlighted:
			return nil;
			break;
		default:
			return nil;
			break;
	}
}

#pragma mark - Theme Methods: General Appearance

/**
 *	returns the background colour of the views
 */
- (UIColor *)backgroundColour
{
	return [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_forest.png"]];
}

#pragma mark - Theme Methods: Label Appearance

/**
 *	returns a dictionary of properties for uilabels
 */
- (NSDictionary *)labelTextDictionary
{
	return @{	UITextAttributeFont				: [UIFont fontWithName:@"Optima" size:18.0f],
				UITextAttributeTextColor		: kYummlyColourMain,
				UITextAttributeTextShadowColor	: kYummlyColourShadow,
				UITextAttributeTextShadowOffset	: [NSValue valueWithUIOffset:UIOffsetMake(0.0f, 1.0f)]};
}

#pragma mark - Theme Methods: Navigation Bar Appearance

/**
 *	returns the image for the navigation bar depending on ber metrics
 *
 *	@param	barMetrics					the metrics of the navigation bar
 */
- (UIImage *)imageForNavigationBarForBarMetrics:(UIBarMetrics)barMetrics
{
	if (barMetrics == UIBarMetricsDefault)
		return [[UIImage imageNamed:@"nav_forest_portrait.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0.0f, 100.0f, 0.0f, 100.0f)];
	else if (barMetrics == UIBarMetricsLandscapePhone)
		return [[UIImage imageNamed:@"nav_forest_landscape.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0.0f, 100.0f, 0.0f, 100.0f)];
	else
		return nil;
}

/**
 *	returns an image for the shadow of the navigation bar
 */
- (UIImage *)imageForNavigationBarShadow
{
	return [UIImage imageNamed:@"topShadow_forest.png"];
}

/**
 *	returns a dictionary for the navigation bar text font, colour etc.
 */
- (NSDictionary *)navigationBarTextDictionary
{
	return @{	UITextAttributeFont				: [UIFont fontWithName:@"Optima" size:24.0f],
				UITextAttributeTextColor		: [UIColor colorWithRed:0.910f green:0.914f blue:0.824f alpha:1.000f],
				UITextAttributeTextShadowColor	: [UIColor colorWithRed:0.224f green:0.173f blue:0.114f alpha:1.000f],
				UITextAttributeTextShadowOffset	: [NSValue valueWithUIOffset:UIOffsetMake(0.0f, -1.0f)]};
}

#pragma mark - Theme Methods: Page Appearance

/**
 *	tint color for the current page item
 */
- (UIColor *)pageCurrentTintColour
{
	return  kYummlyColourMain;
}

/**
 *	tint color for the page items
 */
- (UIColor *)pageTintColour
{
	return kYummlyColourShadow;
}

#pragma mark - Theme Methods: Progress Bar Customisation

/**
 *	returns an image to use for the portion of the track that is not filled
 */
- (UIImage *)imageForProgressBarTrack
{
	return nil;
}

/**
 *	returns the colour to tint the portion of the progress bar that is filled
 */
- (UIColor *)progressBarTintColour
{
	return kYummlyColourMain;
}

/**
 *	returns the colour shown for the portion of the progress bar that is not filled
 */
- (UIColor *)progressBarTrackTintColour
{
	return kYummlyColourShadow;
}

#pragma mark - Theme Methods: Search Bar Appearance

/**
 *
 */
- (UIImage *)backgroundImageForSearchBar
{
	return nil;
}

/**
 *
 *
 *	@param
 */
- (UIImage *)backgroundImageForSearchFieldForState:(UIControlState)controlState
{
	return nil;
}

/**
 *
 *
 *	@param
 */
- (UIImage *)imageForSearchIconForState:(UIControlState)controlState
{
	return [UIImage imageNamed:@"searchbaricon_default_search"];
}

/**
 *
 */
- (UIOffset)offsetForSearchBarText
{
	return UIOffsetMake(0.0f, 0.0f);
}

#pragma mark - Theme Methods: Stepper Appearance

/**
 *	returns an image for the decrement icon on the uistepper control
 */
- (UIImage *)imageForStepperDecrement
{
	return [UIImage imageNamed:@"stepper_forest_decrement.png"];
}

/**
 *	returns an image for the increment icon on the uistepper control
 */
- (UIImage *)imageForStepperDividerSelected
{
	return [UIImage imageNamed:@"stepper_forest_divider_sel.png"];
}

/**
 *	returns an image for the divider of the unselected uistepper control
 */
- (UIImage *)imageForStepperDividerUnselected
{
	return [UIImage imageNamed:@"stepper_forest_divider_uns.png"];
}

/**
 *	returns an image for the divider of the selected uistepper control
 */
- (UIImage *)imageForStepperIncrement
{
	return [UIImage imageNamed:@"stepper_forest_increment.png"];
}

/**
 *	returns an image for a selected section of the uistepper control
 */
- (UIImage *)imageForStepperSelected
{
	return [UIImage imageNamed:@"stepper_forest_bg_sel.png"];
}

/**
 *	returns an image for an unselected section of the uistepper control
 */
- (UIImage *)imageForStepperUnselected
{
	return [UIImage imageNamed:@"stepper_forest_bg_uns.png"];
}

#pragma mark - Theme Methods: Switch Apperance

/**
 *	returns an image for when the uiswitch is off
 */
- (UIImage *)imageForSwitchOff
{
	return [UIImage imageNamed:@"tree_off.png"];
}

/**
 *	returns an image for when the uiswitch is on
 */
- (UIImage *)imageForSwitchOn
{
	return [UIImage imageNamed:@"tree_on.png"];
}

/**
 *	returns the tint colour for the on side of the switch
 */
- (UIColor *)switchOnTintColour
{
	return kYummlyColourMain;
}

/**
 *	returns the tint colour of the 'thumb' (knob) of the switch
 */
- (UIColor *)switchThumbTintColor
{
	return [UIColor whiteColor];
}

/**
 *	return colour used to tint the appearance when the switch is disabled
 */
- (UIColor *)switchTintColour
{
	return kYummlyColourShadow;
}

#pragma mark - Theme Methods: Table View Cell Appearance

/**
 *
 */
- (UIColor *)backgroundColourForTableViewCellSelected:(BOOL)isSelected
{
	if (isSelected)
		return kYummlyColourMain;
	else
		return [UIColor whiteColor];
}

/**
 *	returns a dictionary of properties for the table view cell
 */
- (NSDictionary *)tableViewCellTextDictionarySelected:(BOOL)isSelected
{
	if (isSelected)
		return @{	UITextAttributeFont				: [UIFont fontWithName:@"AvenirNext-Regular" size:14.0f],
					UITextAttributeTextColor		: [UIColor whiteColor],
					UITextAttributeTextShadowColor	: kYummlyColourShadow,
					UITextAttributeTextShadowOffset	: [NSValue valueWithUIOffset:UIOffsetMake(0.0f, 1.0f)]};
	else
		return @{	UITextAttributeFont				: [UIFont fontWithName:@"AvenirNext-Regular" size:14.0f],
					UITextAttributeTextColor		: kYummlyColourMain,
					UITextAttributeTextShadowColor	: kYummlyColourShadow,
					UITextAttributeTextShadowOffset	: [NSValue valueWithUIOffset:UIOffsetMake(0.0f, 1.0f)]};
}

#pragma mark - Theme Methods: Text Field Apperance

/**
 *	returns the background colour to a text field
 */
- (UIColor *)backgroundColourForTextField
{
	return [UIColor clearColor];
}

/**
 *	returns the background image for a text field
 */
- (UIImage *)backgroundImageForTextField
{
	return [[UIImage imageNamed:@"button_background"] resizableImageWithCapInsets:UIEdgeInsetsMake(10.0f, 21.0f, 10.0f, 21.0f)
																	 resizingMode:UIImageResizingModeStretch];
}

/**
 *	returns a view for the left view of a text field
 */
- (UIView *)leftViewForTextField
{
	return [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 10.0f, 1.0f)];
}

/**
 *	returns a dictionary of text attributes for use in a tect field
 */
- (NSDictionary *)textFieldDictionary
{
	return @{	UITextAttributeFont				: [UIFont fontWithName:@"AvenirNext-Regular" size:16.0f],
				UITextAttributeTextColor		: kYummlyColourMain,
				UITextAttributeTextShadowColor	: kYummlyColourShadow,
				UITextAttributeTextShadowOffset	: [NSValue valueWithUIOffset:UIOffsetMake(0.0f, 1.0f)]};
}

/**
 *	returns the uitextviewmode for the left view of a text field
 */
- (UITextFieldViewMode)viewModeForLeftViewInTextField
{
	return UITextFieldViewModeAlways;
}

#pragma mark - Theme Methods: Toolbar Appearance

/**
 *	returns the toolbar background imaging depending on it's position and bar metrics
 *
 *	@param	toolbarPositon					the position of toolbar
 *	@param	barMetrics						the metrics of toolbar
 */
- (UIImage *)backgroundImageForToolbarInPosition:(UIToolbarPosition)toolbarPosition
									  barMetrics:(UIBarMetrics)barMetrics
{
	if (barMetrics == UIBarMetricsDefault)
		switch (toolbarPosition)
		{
			case UIToolbarPositionAny:		return nil;												break;
			case UIToolbarPositionBottom:	return nil;												break;
			case UIToolbarPositionTop:		return nil;												break;
			default:						return nil;												break;
		}
	
	else
		switch (toolbarPosition)
		{
			case UIToolbarPositionAny:		return nil;												break;
			case UIToolbarPositionBottom:	return nil;												break;
			case UIToolbarPositionTop:		return nil;												break;
			default:						return nil;												break;
		}
}

/**
 *	returns the shadow for the bottom of the toolbar
 */
- (UIImage *)imageForToolbarShadowBottom
{
	return nil;
}

/**
 *	returns the shadow for the top of the toolbar
 */
- (UIImage *)imageForToolbarShadowTop
{
	return nil;
}

@end