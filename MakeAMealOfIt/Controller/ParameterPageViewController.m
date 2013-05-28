//
//  ParameterPageViewController.m
//  MakeAMealOfIt
//
//  Created by James Valaitis on 21/05/2013.
//  Copyright (c) 2013 &Beyond. All rights reserved.
//

#import "ParameterPageViewController.h"
#import "RotaryWheel.h"

#pragma mark - Parameters Page View Controller Private Class Extension

@interface ParameterPageViewController () <RotaryProtocol> {}

@property (nonatomic, strong)	RotaryWheel		*selectionWheel;
@property (nonatomic, strong)	NSDictionary	*viewsDictionary;

@end

#pragma mark - Parameters Page View Controller Implementation

@implementation ParameterPageViewController {}

#pragma mark - Autolayout Methods

/**
 *	called when the view controller’s view needs to update its constraints
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
 *	returns a boolean value indicating whether rotation methods are forwarded to child view controllers
 */
- (BOOL)shouldAutomaticallyForwardRotationMethods
{
	return YES;
}

/**
 *	returns whether the view controller’s contents should auto rotate
 */
- (BOOL)shouldAutorotate
{
	return YES;
}

/**
 *	sent to the view controller just before the user interface begins rotating
 *
 *	@param	toInterfaceOrientation		new orientation for the user interface
 *	@param	duration					duration of the pending rotation, measured in seconds
 */
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
								duration:(NSTimeInterval)duration
{
	//	self.selectionWheel.drawnWheel		= NO;
	[self.view setNeedsUpdateConstraints];
}

#pragma mark - RotaryProtocol Methods

/**
 *	the rotary wheel's value has changed
 *
 *	@param	newValue					the value that the wheel is now representing
 */
- (void)wheelDidChangeValue:(NSString *)newValue
{
	
}

#pragma mark - Setter & Getter Methods

/**
 *	a label that is the title of this particular option
 */
- (UILabel *)optionLabel
{
	if (!_optionLabel)
	{
		_optionLabel					= [[UILabel alloc] init];
		_optionLabel.backgroundColor	= [UIColor clearColor];
		[_optionLabel sizeToFit];
		_optionLabel.translatesAutoresizingMaskIntoConstraints	= NO;
		[self.view addSubview:_optionLabel];
	}
	
	return _optionLabel;
}

/**
 *	the rotary selection wheel representing the option petinent to the particular page
 */
- (RotaryWheel *)selectionWheel
{
	if (!_selectionWheel)
	{
		_selectionWheel					= [[RotaryWheel alloc] initWithDelegate:self withSections:self.options.count];
		_selectionWheel.translatesAutoresizingMaskIntoConstraints	= NO;
		[self.view addSubview:_selectionWheel];
	}
	
	return _selectionWheel;
}

/**
 *	this is the dictionary of view to apply constraint to
 */
- (NSDictionary *)viewsDictionary
{
	return @{	@"optionLabel"		: self.optionLabel,
				@"selectionWheel"	: self.selectionWheel};
}

#pragma mark - View Lifecycle

/**
 *	notifies the view controller that its view is about to be added to a view hierarchy
 *
 *	@param	animated					whether the view needs to be added to the window with an animation
 */
- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[self.view setNeedsUpdateConstraints];
	[self.selectionWheel setNeedsLayout];
}

/**
 *	notifies the view controller that its view is about to layout its subviews
 */
- (void)viewWillLayoutSubviews
{
	[super viewWillLayoutSubviews];
	[self.view setNeedsUpdateConstraints];
}

@end