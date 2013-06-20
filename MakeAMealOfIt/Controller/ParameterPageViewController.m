//
//  ParameterPageViewController.m
//  MakeAMealOfIt
//
//  Created by James Valaitis on 21/05/2013.
//  Copyright (c) 2013 &Beyond. All rights reserved.
//

#import "ParameterPageViewController.h"
#import "RotaryWheel.h"
#import "YummlyAPI.h"

#pragma mark - Parameters Page View Controller Private Class Extension

@interface ParameterPageViewController () <RotaryProtocol> {}

/**	The label that will be used to display the title of this page.	*/
@property (nonatomic, strong)	UILabel			*optionLabel;
/**	An array of the titles for each option.	*/
@property (nonatomic, strong)	NSArray			*optionTitles;
/**	The wheel that will be used to display the options.	*/
@property (nonatomic, strong)	RotaryWheel		*selectionWheel;

@end

#pragma mark - Parameters Page View Controller Implementation

@implementation ParameterPageViewController {}

#pragma mark - Autolayout Methods

/**
 *	Called when the view controller’s view needs to update its constraints.
 */
- (void)updateViewConstraints
{
	[super updateViewConstraints];
	
	NSArray *constraints;
	
	//	remove all constraints
	[self.view removeConstraints:self.view.constraints];
	
	if (self.interfaceOrientation == UIInterfaceOrientationPortrait || self.interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown)
	{
		constraints							= [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[optionLabel]-[selectionWheel]-|"
																	options:NSLayoutFormatAlignAllCenterX
																	metrics:nil
																	  views:self.viewsDictionary];
		[self.view addConstraints:constraints];
		
		constraints							= [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[selectionWheel]-|"
																	options:kNilOptions
																	metrics:nil
																	  views:self.viewsDictionary];
		[self.view addConstraints:constraints];
	}
	else
	{
		constraints							= [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[selectionWheel]-|" options:kNilOptions
																	metrics:nil views:self.viewsDictionary];
		[self.view addConstraints:constraints];
		
		constraints							= [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[optionLabel]-[selectionWheel]-(Balance)-|"
																	options:NSLayoutFormatAlignAllCenterY
																	metrics:@{@"Balance": @(self.optionLabel.bounds.size.width + 40)}
																	  views:self.viewsDictionary];
		[self.view addConstraints:constraints];
	}
}

#pragma mark - Autorotation

/**
 *	Sent to the view controller just before the user interface begins rotating.
 *
 *	@param	toInterfaceOrientation		The new orientation for the user interface. The possible values are described in UIInterfaceOrientation.
 *	@param	duration					The duration of the pending rotation, measured in seconds.
 */
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
								duration:(NSTimeInterval)duration
{
	[super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
	[self.view setNeedsUpdateConstraints];
}

#pragma mark - RotaryProtocol Methods

/**
 *	The rotary wheel's value has changed.
 *
 *	@param	newValue					The selected value in the wheel.
 */
- (void)wheelDidChangeValue:(NSString *)newValue
{
	
}

#pragma mark - Setter & Getter Methods

/**
 *	A label that is the title of this particular option.
 *
 *	@return	Fully initialised label to be used as the title of this page.
 */
- (UILabel *)optionLabel
{
	if (!_optionLabel)
	{
		_optionLabel					= [[UILabel alloc] init];
		_optionLabel.backgroundColor	= [UIColor clearColor];
		_optionLabel.font				= kYummlyFontWithSize(20.0f);
		_optionLabel.textColor			= kYummlyColourShadow;
		[_optionLabel sizeToFit];
		_optionLabel.translatesAutoresizingMaskIntoConstraints	= NO;
		[self.view addSubview:_optionLabel];
	}
	
	return _optionLabel;
}

/**
 *	The titles in the options array.
 *
 *	@return	An array of titles from the options array.
 */
- (NSArray *)optionTitles
{
	if (!_optionTitles)
	{
		NSMutableArray *optionTitles	= [[NSMutableArray alloc] initWithCapacity:self.options.count];
		for (NSDictionary *option in self.options)
			if (option[kYummlyMetadataShortDescriptionKey])
				[optionTitles addObject:option[kYummlyMetadataShortDescriptionKey]];
			else if (option[kYummlyMetadataDescriptionKey])
				[optionTitles addObject:option[kYummlyMetadataDescriptionKey]];
		_optionTitles					= optionTitles;
	}
	
	return _optionTitles;
}

/**
 *	The rotary selection wheel representing the option pertinent to the particular page.
 *
 *	@param	A fully initialised wheel UIControl.
 */
- (RotaryWheel *)selectionWheel
{
	//	use lazy instantiation to initialise the wheel with the amount os options we will need, also setting ourself as delegate
	if (!_selectionWheel)
	{
		_selectionWheel					= [[RotaryWheel alloc] initWithDelegate:self withSections:self.options.count];
		_selectionWheel.segmentTitles	= self.optionTitles;
		_selectionWheel.translatesAutoresizingMaskIntoConstraints	= NO;
		[self.view addSubview:_selectionWheel];
	}
	
	return _selectionWheel;
}

/**
 *	This will be used in the label displaying the title of the page.
 *
 *	@param	optionCategoryTitle			The desired title for this page.
 */
- (void)setOptionCategoryTitle:(NSString *)optionCategoryTitle
{
	//	set the label's text with the new option category title
	self.optionLabel.text				= _optionCategoryTitle		= optionCategoryTitle;
}

/**
 *	A dictionary to used when creating visual constraints for this view controller.
 *
 *	@return	A dictionary with of views and appropriate keys.
 */
- (NSDictionary *)viewsDictionary
{
	return @{	@"optionLabel"		: self.optionLabel,
				@"selectionWheel"	: self.selectionWheel};
}

#pragma mark - View Lifecycle

/**
 *	Notifies the view controller that its view is about to be added to a view hierarchy.
 *
 *	@param	animated					If YES, the view is being added to the window using an animation.
 */
- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[self.selectionWheel setNeedsLayout];
}

@end