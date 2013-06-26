//
//  Theme.h
//  Appearance
//
//  Created by James Valaitis on 28/03/2013.
//  Copyright (c) 2013 Adam Burkepile. All rights reserved.
//

#pragma mark - Theme Protocol Definition

@protocol Theme <NSObject>

@optional

#pragma mark - Bar Button Item Appearance

- (NSDictionary *)barButtonTextDictionary;
- (UIImage *)imageForBarButtonDoneForState:(UIControlState)controlState
								barMetrics:(UIBarMetrics)barMetrics;
- (UIImage *)imageForBarButtonForState:(UIControlState)controlState
							barMetrics:(UIBarMetrics)barMetrics;
- (UIOffset)positionForBackButtonBackgroundForBarMetrics:(UIBarMetrics)barMetrics;
- (UIOffset)positionForBackButtonTitleForBarMetrics:(UIBarMetrics)barMetrics;
- (UIOffset)positionForButtonBackgroundForBarMetrics:(UIBarMetrics)barMetrics;
- (UIOffset)positionForButtonTitleForBarMetrics:(UIBarMetrics)barMetrics;
- (UIOffset)positionForTitleForBarMetrics:(UIBarMetrics)barMetrics;

#pragma mark - Button Appearance

- (NSDictionary *)buttonTextDictionary;
- (UIImage *)imageForButtonWithState:(UIControlState)controlState;
- (UIImage *)imageForButtonHighlighted;
- (UIImage *)imageForButtonNormal;

#pragma mark - General Appearance

- (UIColor *)backgroundColour;

#pragma mark - Label Appearance

- (NSDictionary *)labelTextDictionary;

#pragma mark - Navigation Bar Appearance

- (UIImage *)imageForNavigationBarForBarMetrics:(UIBarMetrics)barMetrics;
- (UIImage *)imageForNavigationBarShadow;
- (NSDictionary *)navigationBarTextDictionary;

#pragma mark - Page Control Appearance

- (UIColor *)pageCurrentTintColour;
- (UIColor *)pageTintColour;

#pragma mark - Progress Bar Customisation

- (UIImage *)imageForProgressBar;
- (UIImage *)imageForProgressBarTrack;
- (UIColor *)progressBarTintColour;
- (UIColor *)progressBarTrackTintColour;

#pragma mark - Search Bar Appearance

/**
 *	Called to get the colour for a search bar implementing this theme.
 *
 *	@return	A colour for the background of a search bar.
 */
- (UIColor *)backgroundColourForSearchBar;
- (UIImage *)backgroundImageForSearchBar;
- (UIImage *)backgroundImageForSearchFieldForState:(UIControlState)controlState;
- (UIImage *)imageForSearchIconForState:(UIControlState)controlState;
- (UIOffset)offsetForSearchBarText;

#pragma mark - Stepper Appearance

- (UIImage *)imageForStepperDecrement;
- (UIImage *)imageForStepperDividerSelected;
- (UIImage *)imageForStepperDividerUnselected;
- (UIImage *)imageForStepperIncrement;
- (UIImage *)imageForStepperSelected;
- (UIImage *)imageForStepperUnselected;

#pragma mark - Switch Apperance

- (UIImage *)imageForSwitchOff;
- (UIImage *)imageForSwitchOn;
- (UIColor *)switchOnTintColour;
- (UIColor *)switchThumbTintColor;
- (UIColor *)switchTintColour;

#pragma mark - Tab Bar Appearance

- (UIImage *)backgroundImageForTabBar;
- (UIImage *)selectionIndicatorImageForTabBar;
- (UIImage *)shadowImageForTabBar;

#pragma mark - Tab Bar Item Appearance

- (NSDictionary *)tabBarTextDictionaryForState:(UIControlState)controlState;

#pragma mark - Table View Cell Appearance

- (UIColor *)backgroundColourForTableViewCellSelected:(BOOL)isSelected;
- (NSArray *)coloursForGradient;
- (Class)gradientLayer;
- (NSArray *)locationsOfColours;
- (NSUInteger)numberOfColoursInGradient;
- (NSDictionary *)tableViewCellTextDictionarySelected:(BOOL)isSelected;

#pragma mark - Text Field Appearance

- (UIColor *)backgroundColourForTextField;
- (UIImage *)backgroundImageForTextField;
- (UIView *)leftViewForTextField;
- (NSDictionary *)textFieldDictionary;
- (UITextFieldViewMode)viewModeForLeftViewInTextField;

#pragma mark - Toolbar Appearance

- (UIImage *)backgroundImageForToolbarInPosition:(UIToolbarPosition)toolbarPosition
									  barMetrics:(UIBarMetrics)barMetrics;
- (UIImage *)imageForToolbarShadowBottom;
- (UIImage *)imageForToolbarShadowTop;

@end

#pragma mark - Theme Manager Public Interface

@interface ThemeManager : NSObject

#pragma mark - Class Public Methods

/**
 *	Applies the theme to as many types of views as possible.
 */
+ (void)applyTheme;
/**
 *	Customises a specific bar button item.
 *
 *	@param	barButton					The bar button item to customise.
 *	@param	theme						The theme to use to customise the bar button item .
 */
+ (void)customiseBarButtonItem:(UIBarButtonItem *)barButton
					 withTheme:(id<Theme>)theme;
/**
 *	Customises a uibutton with the set theme.
 *
 *	@param	button						The UIButton to customise.
 *	@param	theme						The theme to use to customise the button .
 */
+ (void)customiseButton:(UIButton *)button
			  withTheme:(id<Theme>)theme;
/**
 *	Customises a specific UILabel.
 *
 *	@param	label						The label to customise.
 *	@param	theme						The theme to use to customise the label.
 */
+ (void)customiseLabel:(UILabel *)label
			 withTheme:(id<Theme>)theme;
/**
 *	Customises a specific navigation bar.
 *
 *	@param	navigationBar				The navigation bar to customise.
 *	@param	theme						The theme to use to customise the navigation bar.
 */
+ (void)customiseNavigationBar:(UINavigationBar *)navigationBar
					 withTheme:(id<Theme>)theme;
/**
 *	Customises a UIPageControl.
 *
 *	@param	pageControl					The page control to customise.
 *	@param	theme						The theme to use to customise the page control.
 */
+ (void)customisePageControl:(UIPageControl *)pageControl
				   withTheme:(id<Theme>)theme;
/**
 *	Customises a UIProgressView.
 *
 *	@param	progressBar					The progress bar to customise.
 *	@param	theme						The theme to use to customise the progress bar.
 */
+ (void)customiseProgressBar:(UIProgressView *)progressBar
				   withTheme:(id<Theme>)theme;
/**
 *	Customises a UISearchBar.
 *
 *	@param	searchBar					The search bar to customise.
 *	@param	theme						the theme to use to customise the search bar.
 */
+ (void)customiseSearchBar:(UISearchBar *)searchBar
				 withTheme:(id<Theme>)theme;
/**
 *	Customises a UIStepper.
 *
 *	@param	stepper						The stepper control to customise.
 *	@param	theme						The theme to use to customise the stepper.
 */
+ (void)customiseStepper:(UIStepper *)stepper
			   withTheme:(id<Theme>)theme;
/**
 *	Customises a UISwitch.
 *
 *	@param	switchControl				The switch control to customise.
 *	@param	theme						The theme to use to customise the switch.
 */
+ (void)customiseSwitch:(UISwitch *)switchControl
			  withTheme:(id<Theme>)theme;
/**
 *	Customises a UITabBar.
 *
 *	@param	tabBar						The tab bar to customise.
 *	@param	theme						The theme to use to customise the tab bar.
 */
+ (void)customiseTabBar:(UITabBar *)tabBar
			  withTheme:(id<Theme>)theme;
/**
 *	Customises a UITabBarItem.
 *
 *	@param	tabBarItem					The tab bar item to customise.
 *	@param	theme						The theme to use to customise the tab bar item.
 */
+ (void)customiseTabBarItem:(UITabBarItem *)tabBarItem
				  withTheme:(id<Theme>)theme;
/**
 *	Customises a UITableViewCell.
 *
 *	@param	switchControl				The table view cell to customise.
 *	@param	theme						The theme to use to customise the table view cell.
 */
+ (void)customiseTableViewCell:(UITableViewCell *)tableViewCell
					 withTheme:(id<Theme>)theme;
/**
 *	Customises a UITextField.
 *
 *	@param	textField					The text field to customise.
 *	@param	theme						The theme to use to customise the text field.
 */
+ (void)customiseTextField:(UITextField *)textField
				 withTheme:(id<Theme>)theme;
/**
 *	Customises a UIToolbar.
 *
 *	@param	toolbar						The toolbar to customise.
 *	@param	theme						The theme to use to customise the toolbar.
 */
+ (void)customiseToolbar:(UIToolbar *)toolbar
			   withTheme:(id<Theme>)theme;
/**
 *	Customises a specific UIView.
 *
 *	@param	view						The view to customise.
 *	@param	theme						The theme to use to customise the view.
 */
+ (void)customiseView:(UIView *)view
			withTheme:(id<Theme>)theme;
/**
 *	Applies a theme as the new standard theme across the application.
 *
 *	@param	theme						Theme to apply.
 */
+ (void)setSharedTheme:(id<Theme>)theme;
/**
 *	Returns the theme.
 *
 *	@return	The standard theme for this application.
 */
+ (id<Theme>)sharedTheme;

@end