//
//  TimerLabel.m
//  MakeAMealOfIt
//
//  Created by James Valaitis on 22/08/2013.
//  Copyright (c) 2013 &Beyond. All rights reserved.
//

#import "TimerLabel.h"

#pragma mark - Timer Label Private Class Extension

@interface TimerLabel () {}

#pragma mark - Public Properties

/**	The label to be placed in the centre of the timer.	*/
@property (nonatomic, strong) UILabel		*label;
/**	An image view with an image of an empty timer.	*/
@property (nonatomic, strong) UIImageView	*timerImageView;

@end

#pragma mark - Timer Label Implementation

@implementation TimerLabel {}

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
	
	[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[timer]|"
																 options:kNilOptions
																 metrics:nil
																   views:self.viewsDictionary]];
	[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[timer]|"
																 options:kNilOptions
																 metrics:nil
																   views:self.viewsDictionary]];
	[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(8)-[label]-(8)-|"
																 options:kNilOptions
																 metrics:nil
																   views:self.viewsDictionary]];
	[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(8)-[label]-(8)-|"
																 options:kNilOptions
																 metrics:nil
																   views:self.viewsDictionary]];
}

#pragma mark - Property Accessor Methods - Getters

/**
 *	The label to be placed in the centre of the timer.
 *
 *	@return	An initialised UILabel.
 */
- (UILabel *)label
{
	if (!_label)
	{
		_label							= [[UILabel alloc] init];
		_label.textAlignment			= NSTextAlignmentCenter;
		
		_label.translatesAutoresizingMaskIntoConstraints	= NO;
		[self addSubview:_label];
	}
	
	return _label;
}

/**
 *	An image view with an image of an empty timer.
 *
 *	@return	An initialised UIImageView with a timer image in it.
 */
- (UIImageView *)timerImageView
{
	if (!_timerImageView)
	{
		UIImage *timer					= [UIImage imageNamed:@"image_emptytimer"];
		_timerImageView					= [[UIImageView alloc] initWithImage:timer];
		_timerImageView.contentMode		= UIViewContentModeScaleAspectFit;
		
		_timerImageView.translatesAutoresizingMaskIntoConstraints	= NO;
		[self addSubview:_timerImageView];
	}
	
	return _timerImageView;
}

/**
 *	A dictionary to used when creating visual constraints for this view controller.
 *
 *	@return	A dictionary with of views and appropriate keys.
 */
- (NSDictionary *)viewsDictionary
{
	return @{@"label"	: self.label,
			 @"timer"	: self.timerImageView};
}

#pragma mark - Property Accessor Methods - Setters

/**
 *	Sets the font of the text.
 *
 *	@param	font						The desired font of the text.
 */
- (void)setFont:(UIFont *)font
{
	if ([_font isEqual:font])			return;
	
	_font								= font;
	self.label.font						= _font;
}

/**
 *	Sets the maximum number of lines to use for rendering text.
 *
 *	@param	numberOfLines				The desired maximum number of lines to use for rendering text.
 */
- (void)setNumberOfLines:(NSUInteger)numberOfLines
{
	if (_numberOfLines == numberOfLines)
		return;
	
	_numberOfLines						= numberOfLines;
	self.label.numberOfLines			= _numberOfLines;
}

/**
 *	Sets the text displayed by the label.
 *
 *	@param	text						The desired text to be displayed byt he label.
 */
- (void)setText:(NSString *)text
{
	if ([_text isEqual:text])			return;
	
	_text								= text;
	self.label.text						= _text;
}

/**
 *	Sets the colour of the text.
 *
 *	@param	textColour					The desired colour of the text.
 */
- (void)setTextColour:(UIColor *)textColour
{
	if ([_textColour isEqual:textColour])
		return;
	
	_textColour							= textColour;
	self.label.textColor				= _textColour;
}

@end