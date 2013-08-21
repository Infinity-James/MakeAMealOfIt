//
//  OverlayActivityIndicator.m
//  MakeAMealOfIt
//
//  Created by James Valaitis on 21/08/2013.
//  Copyright (c) 2013 &Beyond. All rights reserved.
//

#import "OverlayActivityIndicator.h"

@import QuartzCore;

#pragma mark - Overlay Activity Indicator Private Class Extension

@interface OverlayActivityIndicator () {}

#pragma mark - Private Properties

/**	The view to be placed behing the activity indicator.	*/
@property (nonatomic, strong)	UIView						*activityBackgroundView;
/**	Used to show that the recipe image is loading.	*/
@property (nonatomic, strong)	UIActivityIndicatorView		*activityIndicatorView;

@end

#pragma mark - Overlay Activity Indicator Implementation

@implementation OverlayActivityIndicator {}

#pragma mark - Activity Indicator Methods

/**
 *	Starts the animation of the progress indicator.
 */
- (void)startAnimating
{
	self.activityBackgroundView.hidden	= NO;
	[self.activityIndicatorView startAnimating];
}

/**
 *	Stops the animation of the progress indicator.
 */
- (void)stopAnimating
{
	[self.activityIndicatorView stopAnimating];
	self.activityBackgroundView.hidden	= YES;
}

#pragma mark - Auto Layout Methods

/**
 *	Returns whether the receiver depends on the constraint-based layout system.
 *
 *	@return	YES if the view must be in a window using constraint-based layout to function properly, NO otherwise.
 */
+ (BOOL)requiresConstraintBasedLayout
{
	return YES;
}

/**
 *	Update constraints for the view.
 */
- (void)updateConstraints
{
	[super updateConstraints];
	
	[self removeConstraints:self.constraints];
	
	[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[backgroundView]|"
																 options:kNilOptions
																 metrics:nil
																   views:self.viewsDictionary]];
	[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[backgroundView]|"
																 options:kNilOptions
																 metrics:nil
																   views:self.viewsDictionary]];
	
	[self addConstraint:[NSLayoutConstraint constraintWithItem:self.activityIndicatorView
													 attribute:NSLayoutAttributeCenterX
													 relatedBy:NSLayoutRelationEqual
														toItem:self
													 attribute:NSLayoutAttributeCenterX
													multiplier:1.0f
													  constant:0.0f]];
	[self addConstraint:[NSLayoutConstraint constraintWithItem:self.activityIndicatorView
													 attribute:NSLayoutAttributeCenterY
													 relatedBy:NSLayoutRelationEqual
														toItem:self
													 attribute:NSLayoutAttributeCenterY
													multiplier:1.0f
													  constant:0.0f]];
	
	[self bringSubviewToFront:self.activityIndicatorView];
}

#pragma mark - Initialisation

/**
 *	Implemented by subclasses to initialize a new object (the receiver) immediately after memory for it has been allocated.
 *
 *	@return	An initialized object.
 */
- (instancetype)init
{
	if (self = [super init])
	{
	}
	
	return self;
}

#pragma mark - Property Accessor Methods - Getters

/**
 *	The view to be placed behing the activity indicator.
 *
 *	@return	The view to be placed behing the activity indicator.
 */
- (UIView *)activityBackgroundView
{
	if (!_activityBackgroundView)
	{
		_activityBackgroundView						= [[UIView alloc] init];
		self.activityBackgroundView.hidden			= YES;
		_activityBackgroundView.layer.cornerRadius	= 2.0f;
		
		_activityBackgroundView.translatesAutoresizingMaskIntoConstraints	= NO;
		[self addSubview:_activityBackgroundView];
	}
	
	return _activityBackgroundView;
}

/**
 *	The view that shows the user that the recipe image is loading.
 *
 *	@return	A UIActivityIndicatorView representing loading.
 */
- (UIActivityIndicatorView *)activityIndicatorView
{
	if (!_activityIndicatorView)
	{
		_activityIndicatorView			= [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
		_activityIndicatorView.backgroundColor	= [UIColor clearColor];
		
		_activityIndicatorView.translatesAutoresizingMaskIntoConstraints	= NO;
		[self addSubview:_activityIndicatorView];
	}
	
	return _activityIndicatorView;
}

/**
 *	A dictionary to used when creating visual constraints for this view controller.
 *
 *	@return	A dictionary with of views and appropriate keys.
 */
- (NSDictionary *)viewsDictionary
{
	return @{@"backgroundView"	: self.activityBackgroundView,
			 @"activityView"	: self.activityIndicatorView	};
}

#pragma mark - Property Accessor Methods - Setters

/**
 *	Sets the colour of the background of this view.
 *
 *	@param	activityBackgroundColour	The desired colour for the background of this view.
 */
- (void)setActivityBackgroundColour:(UIColor *)activityBackgroundColour
{
	if ([_activityBackgroundColour isEqual:activityBackgroundColour])
		return;
	
	_activityBackgroundColour					= activityBackgroundColour;
	
	self.activityBackgroundView.backgroundColor	= _activityBackgroundColour;
}

/**
 *	Sets the colour of the activity indicator.
 *
 *	@param	activityIndicatorColour		The desired colour of the activity indicator.
 */
- (void)setActivityIndicatorColour:(UIColor *)activityIndicatorColour
{
	if ([_activityIndicatorColour isEqual:activityIndicatorColour])
		return;
	
	_activityIndicatorColour			= activityIndicatorColour;
	
	self.activityIndicatorView.color	= _activityIndicatorColour;
}

#pragma mark - UIView Methods

/**
 *	Returns the natural size for the receiving view, considering only properties of the view itself.
 *
 *	@return	A size indicating the natural size for the receiving view based on its intrinsic properties.
 */
- (CGSize)intrinsicContentSize
{
	return CGSizeMake(64.0f, 64.0f);
}

@end