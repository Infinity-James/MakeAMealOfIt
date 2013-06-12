//
//  Theme.m
//  Appearance
//
//  Created by James Valaitis on 28/03/2013.
//  Copyright (c) 2013 Adam Burkepile. All rights reserved.
//

#import "ThemeManager.h"

#pragma mark - Theme Manager Implementation

@implementation ThemeManager {}

#pragma mark - Static Variables
	
static id<Theme> _theme					= nil;

#pragma mark - Setter & Getter Methods

/**
 *	accepts a theme and applies it
 *
 *	@param	theme						theme to apply
 */
+ (void)setSharedTheme:(id<Theme>)theme
{
	_theme								= theme;
	[self applyTheme];
}

#pragma mark - Singleton Methods

/**
 *	returns the theme
 */
+ (id<Theme>)sharedTheme
{
	return _theme;
}

#pragma mark - Theme General Customisation Methods

/**
 *	applies the theme
 */
+ (void)applyTheme
{
	//	use the bar button item appearance proxy to customise all bar button items
	[self customiseBarButtonItem:[UIBarButtonItem appearance] withTheme:nil];
	
	//	use uibutton to customise all buttons
	//	[self customiseButton:[UIButton appearance]];
	//	this should not be done because stuff goes crazy
	
	//	use uilabel proxy to customise all of them
	//	[self customiseLabel:[UILabel appearance] withTheme:nil];
	
	//	use the navigation bar appearance proxy to change all of the navigation bars and then post the notification
	[self customiseNavigationBar:[UINavigationBar appearance] withTheme:nil];
	[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:kThemeChanged object:nil]];
	
	//	use the page control proxy to customise all page controls
	[self customisePageControl:[UIPageControl appearance] withTheme:nil];
	
	//	use progress view proxy to customise them all
	[self customiseProgressBar:[UIProgressView appearance] withTheme:nil];
	
	//	use search bar proxy to customise all search bars
	[self customiseSearchBar:[UISearchBar appearance] withTheme:nil];
	
	//	use the uistepper proxy to customise all uisteppers
	[self customiseStepper:[UIStepper appearance] withTheme:nil];
	
	//	use uiswitch proxy to customise all switches
	[self customiseSwitch:[UISwitch appearance] withTheme:nil];
	
	//	customise all uitableviewcells
	//	[self customiseTableViewCell:[UITableViewCell appearance] withTheme:nil];
	
	//	set uitextfield proxy to customise them all
	[self customiseTextField:[UITextField appearance] withTheme:nil];
	
	//	set the uitoolbar proxy to customise all toolbar
	[self customiseToolbar:[UIToolbar appearance] withTheme:nil];
}

#pragma mark - Theme Specific Customisation Methods

/**
 *	customises a specific bar button item
 *
 *	@param	barButton					the bar button item to customise
 *	@param	theme						the theme to use to customise the bar button item 
 */
+ (void)customiseBarButtonItem:(UIBarButtonItem *)barButton withTheme:(id<Theme>)theme
{
	//	if no theme is passed in get the chosen theme
	if (!theme)
		theme							= self.sharedTheme;
	
	//	customise the normal bar button item
	[barButton setBackgroundImage:[theme imageForBarButtonForState:UIControlStateNormal barMetrics:UIBarMetricsDefault]
						 forState:UIControlStateNormal
					   barMetrics:UIBarMetricsDefault];
	[barButton setBackgroundImage:[theme imageForBarButtonForState:UIControlStateNormal barMetrics:UIBarMetricsLandscapePhone]
						 forState:UIControlStateNormal
					   barMetrics:UIBarMetricsLandscapePhone];
	[barButton setBackgroundImage:[theme imageForBarButtonForState:UIControlStateHighlighted barMetrics:UIBarMetricsDefault]
						 forState:UIControlStateHighlighted
					   barMetrics:UIBarMetricsDefault];
	[barButton setBackgroundImage:[theme imageForBarButtonForState:UIControlStateHighlighted barMetrics:UIBarMetricsLandscapePhone]
						 forState:UIControlStateHighlighted
					   barMetrics:UIBarMetricsLandscapePhone];
	
	//	customise the 'done' bar button item
	[barButton setBackgroundImage:[theme imageForBarButtonDoneForState:UIControlStateNormal barMetrics:UIBarMetricsDefault]
						 forState:UIControlStateNormal
							style:UIBarButtonItemStyleDone
					   barMetrics:UIBarMetricsDefault];
	[barButton setBackgroundImage:[theme imageForBarButtonDoneForState:UIControlStateNormal barMetrics:UIBarMetricsLandscapePhone]
						 forState:UIControlStateNormal
							style:UIBarButtonItemStyleDone
					   barMetrics:UIBarMetricsLandscapePhone];
	[barButton setBackgroundImage:[theme imageForBarButtonDoneForState:UIControlStateNormal barMetrics:UIBarMetricsDefault]
						 forState:UIControlStateHighlighted
							style:UIBarButtonItemStyleDone
					   barMetrics:UIBarMetricsDefault];
	[barButton setBackgroundImage:[theme imageForBarButtonDoneForState:UIControlStateNormal barMetrics:UIBarMetricsLandscapePhone]
						 forState:UIControlStateHighlighted
							style:UIBarButtonItemStyleDone
					   barMetrics:UIBarMetricsLandscapePhone];
	
	//	set the title text attributes for the bar button item
	[barButton setTitleTextAttributes:[theme barButtonTextDictionary] forState:UIControlStateNormal];
}

/**
 *	customises a uibutton with the set theme
 *
 *	@param	button						the uibutton to customise
 *	@param	theme						the theme to use to customise the button 
 */
+ (void)customiseButton:(UIButton *)button withTheme:(id<Theme>)theme
{
	//	if no theme is passed in get the chosen theme
	if (!theme)
		theme							= self.sharedTheme;
	
	//	customise the button properties
	button.titleLabel.font				= theme.buttonTextDictionary[UITextAttributeFont];
	[button setTitleColor:theme.buttonTextDictionary[UITextAttributeTextColor] forState:UIControlStateNormal];
	//button.titleLabel.textColor			= theme.buttonTextDictionary[UITextAttributeTextColor];
	//button.titleLabel.shadowColor		= theme.buttonTextDictionary[UITextAttributeTextShadowColor];
	[button setTitleShadowColor:theme.buttonTextDictionary[UITextAttributeTextShadowColor] forState:UIControlStateNormal];
	button.titleLabel.shadowOffset		= ((NSValue *)theme.buttonTextDictionary[UITextAttributeTextShadowOffset]).CGSizeValue;
	
	//	set the background images for the button
	[button setBackgroundImage:[theme imageForButtonWithState:UIControlStateNormal] forState:UIControlStateNormal];
	[button setBackgroundImage:[theme imageForButtonWithState:UIControlStateHighlighted] forState:UIControlStateHighlighted];
}

/**
 *	customises a specific uilabel
 *
 *	@param	label						the label to customise
 *	@param	theme						the theme to use to customise the label
 */
+ (void)customiseLabel:(UILabel *)label withTheme:(id<Theme>)theme
{
	//	if no theme is passed in get the chosen theme
	if (!theme)
		theme							= self.sharedTheme;
	
	//	customise the uilabel
	label.font							= theme.labelTextDictionary[UITextAttributeFont];
	label.textColor						= theme.labelTextDictionary[UITextAttributeTextColor];
	label.shadowColor					= theme.labelTextDictionary[UITextAttributeTextShadowColor];
	label.shadowOffset					= ((NSValue *)theme.labelTextDictionary[UITextAttributeTextShadowOffset]).CGSizeValue;
}

/**
 *	customises a specific navigation bar
 *
 *	@param	navigationBar				the navigation bar to customise
 *	@param	theme						the theme to use to customise the navigation bar 
 */
+ (void)customiseNavigationBar:(UINavigationBar *)navigationBar withTheme:(id<Theme>)theme
{
	//	if no theme is passed in get the chosen theme
	if (!theme)
		theme							= self.sharedTheme;
	
	//	customise the navigation bar
	[navigationBar setBackgroundImage:[theme imageForNavigationBarForBarMetrics:UIBarMetricsDefault] forBarMetrics:UIBarMetricsDefault];
	[navigationBar setBackgroundImage:[theme imageForNavigationBarForBarMetrics:UIBarMetricsLandscapePhone] forBarMetrics:UIBarMetricsLandscapePhone];
	[navigationBar setShadowImage:[theme imageForNavigationBarShadow]];
	[navigationBar setTitleTextAttributes:[theme navigationBarTextDictionary]];
}

/**
 *	customises a uipagecontrol
 *
 *	@param	pageControl					the page control to customise
 *	@param	theme						the theme to use to customise the page control
 */
+ (void)customisePageControl:(UIPageControl *)pageControl withTheme:(id<Theme>)theme
{
	//	if no theme is passed in get the chosen theme
	if (!theme)
		theme							= self.sharedTheme;
	
	//	customise the look of the page control
	[pageControl setCurrentPageIndicatorTintColor:[theme pageCurrentTintColour]];
	[pageControl setPageIndicatorTintColor:[theme pageTintColour]];
}

/**
 *	customises a progress view
 *
 *	@param	progressBar					the progress bar to customise
 *	@param	theme						the theme to use to customise the progress bar
 */
+ (void)customiseProgressBar:(UIProgressView *)progressBar withTheme:(id<Theme>)theme
{
	//	if no theme is passed in get the chosen theme
	if (!theme)
		theme							= self.sharedTheme;
	
	//	customise the tint colours of the progress bar
	[progressBar setProgressTintColor:[theme progressBarTintColour]];
	[progressBar setTrackTintColor:[theme progressBarTrackTintColour]];
	
	//	use images for the progress bar
	[progressBar setProgressImage:[theme imageForProgressBar]];
	[progressBar setTrackImage:[theme imageForProgressBarTrack]];
}

/**
 *	customises a uisearchbar
 *
 *	@param	searchBar					the uistepper to customise
 *	@param	theme						the theme to use to customise the search bar
 */
+ (void)customiseSearchBar:(UISearchBar *)searchBar withTheme:(id<Theme>)theme
{
	//	if no theme is passed in get the chosen theme
	if (!theme)
		theme							= self.sharedTheme;
	
	//	customise the whole of the search bar
	searchBar.backgroundImage			= [theme backgroundImageForSearchBar];
	[searchBar setSearchFieldBackgroundImage:[theme backgroundImageForSearchFieldForState:UIControlStateNormal] forState:UIControlStateNormal];
	[searchBar setImage:[theme imageForSearchIconForState:UIControlStateNormal] forSearchBarIcon:UISearchBarIconSearch state:UIControlStateNormal];
	[searchBar setSearchTextPositionAdjustment:[theme offsetForSearchBarText]];
}

/**
 *	customises a uistepper
 *
 *	@param	stepper						the uistepper to customise
 *	@param	theme						the theme to use to customise the stepper
 */
+ (void)customiseStepper:(UIStepper *)stepper withTheme:(id<Theme>)theme
{
	//	if no theme is passed in get the chosen theme
	if (!theme)
		theme							= self.sharedTheme;
	
	//	customise the actual stepper buttons
	[stepper setBackgroundImage:[theme imageForStepperUnselected] forState:UIControlStateNormal];
	[stepper setBackgroundImage:[theme imageForStepperSelected] forState:UIControlStateHighlighted];
	
	//	customise the dividers of the stepper
	[stepper setDividerImage:[theme imageForStepperDividerUnselected] forLeftSegmentState:UIControlStateNormal rightSegmentState:UIControlStateNormal];
	[stepper setDividerImage:[theme imageForStepperDividerSelected] forLeftSegmentState:UIControlStateNormal rightSegmentState:UIControlStateSelected];
	[stepper setDividerImage:[theme imageForStepperDividerSelected] forLeftSegmentState:UIControlStateSelected rightSegmentState:UIControlStateNormal];
	[stepper setDividerImage:[theme imageForStepperDividerSelected] forLeftSegmentState:UIControlStateSelected rightSegmentState:UIControlStateSelected];
	
	//	customise the increment and decrement icons
	[stepper setDecrementImage:[theme imageForStepperDecrement] forState:UIControlStateNormal];
	[stepper setIncrementImage:[theme imageForStepperIncrement] forState:UIControlStateNormal];
}

/**
 *	customises a uiswitch
 *
 *	@param	switchControl				the uiswitch to customise
 *	@param	theme						the theme to use to customise the switch
 */
+ (void)customiseSwitch:(UISwitch *)switchControl withTheme:(id<Theme>)theme
{
	//	if no theme is passed in get the chosen theme
	if (!theme)
		theme							= self.sharedTheme;
	
	//	customise the tint colour of the switch
	[switchControl setTintColor:[theme switchTintColour]];
	[switchControl setThumbTintColor:[theme switchThumbTintColor]];
	[switchControl setOnTintColor:[theme switchOnTintColour]];
	[switchControl setOnImage:[theme imageForSwitchOn]];
	[switchControl setOffImage:[theme imageForSwitchOff]];
}

/**
 *	customises a uitabbar
 *
 *	@param	tabBar						the tab bar to customise
 *	@param	theme						the theme to use to customise the tab bar
 */
+ (void)customiseTabBar:(UITabBar *)tabBar withTheme:(id<Theme>)theme
{
	//	if no theme is passed in get the chosen theme
	if (!theme)
		theme							= self.sharedTheme;
	
	tabBar.backgroundImage				= [theme backgroundImageForTabBar];
	tabBar.selectionIndicatorImage		= [theme selectionIndicatorImageForTabBar];
	tabBar.shadowImage					= [theme shadowImageForTabBar];
}

/**
 *	customises a uitabbaritem
 *
 *	@param	tabBarItem					the tab bar item to customise
 *	@param	theme						the theme to use to customise the tab bar item
 */
+ (void)customiseTabBarItem:(UITabBarItem *)tabBarItem withTheme:(id<Theme>)theme
{
	//	if no theme is passed in get the chosen theme
	if (!theme)
		theme							= self.sharedTheme;
	
	[tabBarItem setTitleTextAttributes:[theme tabBarTextDictionaryForState:UIControlStateNormal] forState:UIControlStateNormal];
}

/**
 *	customises a uitableviewcell
 *
 *	@param	switchControl				the table view cell to customise
 *	@param	theme						the theme to use to customise the table view cell
 */
+ (void)customiseTableViewCell:(UITableViewCell *)tableViewCell withTheme:(id<Theme>)theme
{
	//	if no theme is passed in get the chosen theme
	if (!theme)
		theme							= self.sharedTheme;
	
	BOOL isSelected						= tableViewCell.isSelected;
	
	//	set the general appearance
	tableViewCell.backgroundColor		= [theme backgroundColourForTableViewCellSelected:isSelected];
	
	//	customise the table view cell's text properties
	tableViewCell.textLabel.font		= [theme tableViewCellTextDictionarySelected:isSelected][UITextAttributeFont];
	tableViewCell.textLabel.textColor	= [theme tableViewCellTextDictionarySelected:isSelected][UITextAttributeTextColor];
	tableViewCell.textLabel.shadowColor	= [theme tableViewCellTextDictionarySelected:isSelected][UITextAttributeTextShadowColor];
	tableViewCell.textLabel.shadowOffset= ((NSValue *)[theme tableViewCellTextDictionarySelected:isSelected][UITextAttributeTextShadowOffset]).CGSizeValue;
}

/**
 *	customise a uitextfield
 *
 *	@param	textField					the uitextfield to customise
 *	@param	theme						the theme to use to customise the text field
 */
+ (void)customiseTextField:(UITextField *)textField withTheme:(id<Theme>)theme
{
	//	if no theme is passed in get the chosen theme
	if (!theme)
		theme							= self.sharedTheme;
	
	textField.backgroundColor			= [theme backgroundColourForTextField];
	textField.background				= [theme backgroundImageForTextField];
	textField.font						= [theme textFieldDictionary][UITextAttributeFont];
	textField.leftView					= [theme leftViewForTextField];
	textField.leftViewMode				= [theme viewModeForLeftViewInTextField];
	textField.textColor					= [theme textFieldDictionary][UITextAttributeTextColor];
}

/**
 *	customises a uitoolbar
 *
 *	@param	toolbar						the uitoolbar to customise
 *	@param	theme						the theme to use to customise the toolbar
 */
+ (void)customiseToolbar:(UIToolbar *)toolbar withTheme:(id<Theme>)theme
{
	//	if no theme is passed in get the chosen theme
	if (!theme)
		theme							= self.sharedTheme;
	
	[toolbar setShadowImage:theme.imageForToolbarShadowBottom forToolbarPosition:UIToolbarPositionBottom];
	[toolbar setShadowImage:theme.imageForToolbarShadowTop forToolbarPosition:UIToolbarPositionTop];
	[toolbar setBackgroundImage:[theme backgroundImageForToolbarInPosition:UIToolbarPositionTop barMetrics:UIBarMetricsDefault] forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
}

/**
 *	customise a specific view
 *
 *	@param	view						the view to customise
 *	@param	theme						the theme to use to customise the view
 */
+ (void)customiseView:(UIView *)view withTheme:(id<Theme>)theme
{
	//	if no theme is passed in get the chosen theme
	if (!theme)
		theme							= self.sharedTheme;
	
	//	set the view's background colour
	UIColor *backgroundColour			= [theme backgroundColour];
	[view setBackgroundColor:backgroundColour];
}

@end