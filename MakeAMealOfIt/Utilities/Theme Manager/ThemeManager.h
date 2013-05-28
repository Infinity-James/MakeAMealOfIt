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

- (NSArray *)coloursForGradient;
- (Class)gradientLayer;
- (NSArray *)locationsOfColours;
- (NSUInteger)numberOfColoursInGradient;
- (NSDictionary *)tableViewCellTextDictionary;

#pragma mark - Text Field Appearance

- (UIColor *)backgroundColourForTextField;
- (NSDictionary *)textFieldDictionary;

#pragma mark - Toolbar Appearance

- (UIImage *)backgroundImageForToolbarInPosition:(UIToolbarPosition)toolbarPosition
									  barMetrics:(UIBarMetrics)barMetrics;
- (UIImage *)imageForToolbarShadowBottom;
- (UIImage *)imageForToolbarShadowTop;

@end

#pragma mark - Theme Manager Public Interface

@interface ThemeManager : NSObject

#pragma mark - Class Public Methods

+ (void)applyTheme;
+ (void)customiseBarButtonItem:(UIBarButtonItem *)barButton
					 withTheme:(id<Theme>)theme;
+ (void)customiseButton:(UIButton *)button
			  withTheme:(id<Theme>)theme;
+ (void)customiseLabel:(UILabel *)label
			 withTheme:(id<Theme>)theme;
+ (void)customiseNavigationBar:(UINavigationBar *)navigationBar
					 withTheme:(id<Theme>)theme;
+ (void)customisePageControl:(UIPageControl *)pageControl
				   withTheme:(id<Theme>)theme;
+ (void)customiseProgressBar:(UIProgressView *)progressBar
				   withTheme:(id<Theme>)theme;
+ (void)customiseSearchBar:(UISearchBar *)searchBar
				 withTheme:(id<Theme>)theme;
+ (void)customiseStepper:(UIStepper *)stepper
			   withTheme:(id<Theme>)theme;
+ (void)customiseTableViewCell:(UITableViewCell *)tableViewCell
					 withTheme:(id<Theme>)theme;
+ (void)customiseTextField:(UITextField *)textField
				 withTheme:(id<Theme>)theme;
+ (void)customiseToolbar:(UIToolbar *)toolbar
			   withTheme:(id<Theme>)theme;
+ (void)customiseView:(UIView *)view
			withTheme:(id<Theme>)theme;
+ (void)setSharedTheme:(id<Theme>)theme;
+ (id<Theme>)sharedTheme;

@end