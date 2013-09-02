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
	NSShadow *shadow					= [[NSShadow alloc] init];
	shadow.shadowBlurRadius				= kShadowBlur;
	shadow.shadowColor					= [UIColor clearColor];//[[UIColor alloc] initWithRed:0.2f green:0.2f blue:0.2f alpha:1.0f];
	shadow.shadowOffset					= CGSizeMake(0.0f, 0.0f);
	
	return @{	NSFontAttributeName				: kYummlyFontWithSize(16.0f),
				NSForegroundColorAttributeName	: kYummlyColourMain,
				NSShadowAttributeName			: shadow};
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
			case UIControlStateNormal:			break;
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
			case UIControlStateNormal:			break;
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

#pragma mark - Theme Methods: Button Appearance

/**
 *	returns a dictionary of properties for uibuttons
 */
- (NSDictionary *)buttonTextDictionary
{
	NSShadow *shadow					= [[NSShadow alloc] init];
	shadow.shadowBlurRadius				= kShadowBlur;
	shadow.shadowColor					= kYummlyColourShadow;
	shadow.shadowOffset					= CGSizeMake(0.0f, 0.0f);
	
	return @{	NSFontAttributeName				: kYummlyFontWithSize(FontSizeForTextStyle(UIFontTextStyleBody)),
				NSForegroundColorAttributeName	: kYummlyColourMain,
				NSShadowAttributeName			: shadow};
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
			return nil;
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
	return nil;
}

#pragma mark - Theme Methods: Label Appearance

/**
 *	returns a dictionary of properties for uilabels
 */
- (NSDictionary *)labelTextDictionary
{
	NSShadow *shadow					= [[NSShadow alloc] init];
	shadow.shadowBlurRadius				= kShadowBlur;
	shadow.shadowColor					= kYummlyColourShadow;
	shadow.shadowOffset					= CGSizeMake(0.0f, 1.0f);
	
	return @{	NSFontAttributeName				: kYummlyFontWithSize(FontSizeForTextStyle(UIFontTextStyleBody)),
				NSForegroundColorAttributeName	: kYummlyColourMain,
				NSShadowAttributeName			: shadow};
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
		return nil;
	else if (barMetrics == UIBarMetricsLandscapePhone)
		return nil;
	else
		return nil;
}

/**
 *	returns an image for the shadow of the navigation bar
 */
- (UIImage *)imageForNavigationBarShadow
{
	return nil;
}

/**
 *	returns a dictionary for the navigation bar text font, colour etc.
 */
- (NSDictionary *)navigationBarTextDictionary
{
	NSShadow *shadow					= [[NSShadow alloc] init];
	shadow.shadowBlurRadius				= kShadowBlur;
	shadow.shadowColor					= kYummlyColourShadow;
	shadow.shadowOffset					= CGSizeMake(0.0f, 1.0f);
	
	return @{	NSFontAttributeName				: [UIFont fontWithName:@"AvenirNext-Regular" size:16.0f],
				NSForegroundColorAttributeName	: kYummlyColourMain,
				NSShadowAttributeName			: shadow};
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
 *
 */
- (UIImage *)imageForProgressBar
{
	return nil;
}

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
 *	Called to get the colour for a search bar implementing this theme.
 *
 *	@return	A colour for the background of a search bar.
 */
- (UIColor *)backgroundColourForSearchBar
{
	return [UIColor grayColor];
}

/**
 *	returns the background image for the search bar
 */
- (UIImage *)backgroundImageForSearchBar
{
	return nil;
}

/**
 *	called by the theme manager to get the background image for a search bar
 *
 *	@param	controlState				the state of the search field
 *
 *	@return	background image for the text field of the search bar
 */
- (UIImage *)backgroundImageForSearchFieldForState:(UIControlState)controlState
{
	return nil;
}

/**
 *	called to get the theme manager image for a search icon for a search bar
 *
 *	@param	controlState				the state of the search bar
 *
 *	@return	the image for the search icon of the search bar
 */
- (UIImage *)imageForSearchIconForState:(UIControlState)controlState
{
	return [UIImage imageNamed:@"searchbar_icon_default_search"];
}

/**
 *	called by the theme manager to get the offset for some text inside a search bar
 *
 *	@return	the offset for the text inside the search bar field
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
	return nil;
}

/**
 *	returns an image for the increment icon on the uistepper control
 */
- (UIImage *)imageForStepperDividerSelected
{
	return nil;
}

/**
 *	returns an image for the divider of the unselected uistepper control
 */
- (UIImage *)imageForStepperDividerUnselected
{
	return nil;
}

/**
 *	returns an image for the divider of the selected uistepper control
 */
- (UIImage *)imageForStepperIncrement
{
	return nil;
}

/**
 *	returns an image for a selected section of the uistepper control
 */
- (UIImage *)imageForStepperSelected
{
	return nil;
}

/**
 *	returns an image for an unselected section of the uistepper control
 */
- (UIImage *)imageForStepperUnselected
{
	return nil;
}

#pragma mark - Theme Methods: Switch Apperance

/**
 *	returns an image for when the uiswitch is off
 */
- (UIImage *)imageForSwitchOff
{
	return nil;
}

/**
 *	returns an image for when the uiswitch is on
 */
- (UIImage *)imageForSwitchOn
{
	return nil;
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
	NSShadow *shadow					= [[NSShadow alloc] init];
	shadow.shadowBlurRadius				= kShadowBlur;
	shadow.shadowColor					= kYummlyColourShadow;
	shadow.shadowOffset					= CGSizeMake(0.0f, 0.0f);
	
	if (isSelected)
		return @{	NSFontAttributeName				: kYummlyFontWithSize(FontSizeForTextStyle(UIFontTextStyleFootnote)),
					NSForegroundColorAttributeName	: [UIColor whiteColor],
					NSShadowAttributeName			: shadow};
	else
		return @{	NSFontAttributeName				: kYummlyFontWithSize(FontSizeForTextStyle(UIFontTextStyleFootnote)),
					NSForegroundColorAttributeName	: kYummlyColourMain,
					NSShadowAttributeName			: shadow};
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
	return [[UIImage imageNamed:@"button_background_normal_yummly"] resizableImageWithCapInsets:UIEdgeInsetsMake(10.0f, 21.0f, 10.0f, 21.0f)
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
	NSShadow *shadow					= [[NSShadow alloc] init];
	shadow.shadowBlurRadius				= kShadowBlur;
	shadow.shadowColor					= kYummlyColourShadow;
	shadow.shadowOffset					= CGSizeMake(0.0f, 1.0f);
	
	return @{	NSFontAttributeName				: kYummlyFontWithSize(FontSizeForTextStyle(UIFontTextStyleBody)),
				NSForegroundColorAttributeName	: kYummlyColourMain,
				NSShadowAttributeName			: shadow};
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